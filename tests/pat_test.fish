#!/usr/bin/env fish
#
# Integration tests for the pat function (PAT management via pass).
# Run: fish tests/pat_test.fish
#
# Uses a temp directory for registry + mock pass store. No real GPG needed.

# ---------------------------------------------------------------------------
# Test infrastructure
# ---------------------------------------------------------------------------

set --global __test_passed 0
set --global __test_failed 0
set --global __test_errors

function __test_setup
    set --global TMPDIR (mktemp --directory /tmp/pat_test.XXXXXX)
    mkdir --parents $TMPDIR/pass

    # Expand template and source pat functions
    set --local pat_src $TMPDIR/pat.fish
    set --local pat_tmpl (status dirname)/../private_dot_config/fish/functions/pat.fish.tmpl
    chezmoi execute-template <$pat_tmpl >$pat_src 2>/dev/null
    # If template guard excluded everything (devcontainer), strip template lines
    if not test -s $pat_src
        string replace --all --regex '^\{\{.*\}\}' '' <$pat_tmpl >$pat_src
    end
    source $pat_src

    # Override registry path to use temp dir
    function __pat_registry_path
        echo $TMPDIR/pats.json
    end

    # Mock pass: reads/writes plain files under $TMPDIR/pass/
    function pass
        switch $argv[1]
            case show
                set --local path $TMPDIR/pass/$argv[2]
                if test -f $path
                    cat $path
                    return 0
                else
                    echo "Error: $argv[2] is not in the password store." >&2
                    return 1
                end
            case insert
                # Parse flags to find the path (last arg)
                set --local pass_path
                for arg in $argv[2..-1]
                    switch $arg
                        case --multiline --force -m -f
                            continue
                        case '*'
                            set pass_path $arg
                    end
                end
                if test -z "$pass_path"
                    return 1
                end
                mkdir --parents (dirname $TMPDIR/pass/$pass_path)
                cat >$TMPDIR/pass/$pass_path
                return 0
            case '*'
                return 1
        end
    end

    # Mock xdg-open: record URL
    function xdg-open
        echo $argv[1] >$TMPDIR/opened_url
    end
end

function __test_teardown
    rm --recursive --force $TMPDIR
end

function __test_strip_color --description "Strip ANSI color codes from input"
    string replace --all --regex '\e\[[0-9;]*m' '' -- $argv
end

function __test_run --description "Run a test case"
    set --local name $argv[1]
    set --local expected_result $argv[2] # pass or fail — meta, not used here
    # Actual pass/fail determined by caller
end

function __test_pass
    set --local name $argv[1]
    set __test_passed (math $__test_passed + 1)
    echo "[PASS] $name"
end

function __test_fail
    set --local name $argv[1]
    set --local detail $argv[2..-1]
    set __test_failed (math $__test_failed + 1)
    echo "[FAIL] $name"
    if test -n "$detail"
        echo "       $detail"
    end
end

function __test_write_registry --description "Write a test registry JSON file"
    echo $argv[1] >$TMPDIR/pats.json
end

function __test_write_pass --description "Write a mock pass entry"
    set --local pass_path $argv[1]
    set --local value $argv[2]
    mkdir --parents (dirname $TMPDIR/pass/$pass_path)
    echo $value >$TMPDIR/pass/$pass_path
end

function __test_future_date --description "Return YYYY-MM-DD N days from now"
    date --date="+$argv[1] days" +%Y-%m-%d
end

function __test_past_date --description "Return YYYY-MM-DD N days ago"
    date --date="-$argv[1] days" +%Y-%m-%d
end

# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------

function test_help_no_args
    set --local out (pat 2>&1)
    if string match --quiet '*Usage: pat*' "$out"
        __test_pass "help: pat with no args shows help"
    else
        __test_fail "help: pat with no args shows help" "expected Usage text"
    end
end

function test_help_flag
    set --local out (pat --help 2>&1)
    if string match --quiet '*Usage: pat*' "$out"
        __test_pass "help: pat --help shows help"
    else
        __test_fail "help: pat --help shows help" "expected Usage text"
    end
end

function test_help_h_flag
    set --local out (pat -h 2>&1)
    if string match --quiet '*Usage: pat*' "$out"
        __test_pass "help: pat -h shows help"
    else
        __test_fail "help: pat -h shows help" "expected Usage text"
    end
end

function test_unknown_command
    set --local out (pat bogus 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*unknown command*' "$out"
        __test_pass "error: pat bogus returns exit 1 + error message"
    else
        __test_fail "error: pat bogus returns exit 1 + error message" "exit=$code out=$out"
    end
end

function test_deps_missing_jq
    # Temporarily override __pat_check_deps to simulate missing jq
    function __pat_check_deps
        echo "pat: jq not found" >&2
        return 1
    end

    set --local out (pat list 2>&1)
    set --local code $status

    # Restore original
    source $TMPDIR/pat.fish

    if test $code -eq 1; and string match --quiet '*jq not found*' "$out"
        __test_pass "deps: missing jq detected"
    else
        __test_fail "deps: missing jq detected" "exit=$code out=$out"
    end
end

function test_deps_missing_pass
    function __pat_check_deps
        echo "pat: pass not found" >&2
        return 1
    end

    set --local out (pat list 2>&1)
    set --local code $status

    source $TMPDIR/pat.fish

    if test $code -eq 1; and string match --quiet '*pass not found*' "$out"
        __test_pass "deps: missing pass detected"
    else
        __test_fail "deps: missing pass detected" "exit=$code out=$out"
    end
end

function test_list_empty_registry
    __test_write_registry '{}'
    # Empty JSON object is valid but has no keys — jq 'keys[]' returns nothing
    # __pat_check_registry checks -s (not empty) — '{}' is 2 bytes, passes
    set --local out (pat list 2>&1)
    set --local code $status
    if test $code -eq 0
        __test_pass "list: empty registry {} shows header only"
    else
        __test_fail "list: empty registry {} shows header only" "exit=$code out=$out"
    end
end

function test_list_missing_registry
    rm --force $TMPDIR/pats.json
    set --local out (pat list 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*registry not found*' "$out"
        __test_pass "list: missing registry file returns error"
    else
        __test_fail "list: missing registry file returns error" "exit=$code out=$out"
    end
end

function test_list_valid_entries
    set --local expired (__test_past_date 10)
    set --local warning (__test_future_date 3)
    set --local ok (__test_future_date 60)

    __test_write_registry '{
        "expired_pat": {"service":"svc1","name":"Expired","pass_path":"dev/e","env_var":"E_TOK","scopes":"read","expires":"'$expired'","renew_url":"","login_cmd":""},
        "warn_pat": {"service":"svc2","name":"Warning","pass_path":"dev/w","env_var":"W_TOK","scopes":"write","expires":"'$warning'","renew_url":"","login_cmd":""},
        "ok_pat": {"service":"svc3","name":"OK Token","pass_path":"dev/o","env_var":"O_TOK","scopes":"admin","expires":"'$ok'","renew_url":"","login_cmd":""}
    }'

    set --local out (__test_strip_color (pat list 2>&1))
    set --local has_expired (string match --quiet '*EXPIRED*' "$out"; and echo yes; or echo no)
    set --local has_warn (string match --quiet '*WARN*' "$out"; and echo yes; or echo no)
    set --local has_ok (string match --quiet '*OK*' "$out"; and echo yes; or echo no)

    if test "$has_expired" = yes; and test "$has_warn" = yes; and test "$has_ok" = yes
        __test_pass "list: shows EXPIRED, WARN, and OK entries"
    else
        __test_fail "list: shows EXPIRED, WARN, and OK entries" "expired=$has_expired warn=$has_warn ok=$has_ok"
    end
end

function test_list_ls_alias
    set --local ok_date (__test_future_date 60)
    __test_write_registry '{"test_alias":{"service":"svc","name":"Alias Test","pass_path":"dev/a","env_var":"A","scopes":"","expires":"'$ok_date'","renew_url":"","login_cmd":""}}'

    set --local out (__test_strip_color (pat ls 2>&1))
    if string match --quiet '*test_alias*' "$out"
        __test_pass "list: pat ls alias works"
    else
        __test_fail "list: pat ls alias works" "out=$out"
    end
end

function test_check_empty_registry
    __test_write_registry '{}'
    set --local out (pat check 2>&1)
    set --local code $status
    if test $code -eq 0; and test -z "$out"
        __test_pass "check: empty registry produces no output"
    else
        __test_fail "check: empty registry produces no output" "exit=$code out=$out"
    end
end

function test_check_expired
    set --local expired (__test_past_date 5)
    __test_write_registry '{"exp":{"service":"s","name":"Expired Token","pass_path":"dev/e","env_var":"E","scopes":"","expires":"'$expired'","renew_url":"","login_cmd":""}}'

    set --local out (__test_strip_color (pat check 2>&1))
    if string match --quiet '*EXPIRED*' "$out"
        __test_pass "check: shows EXPIRED for past-due entry"
    else
        __test_fail "check: shows EXPIRED for past-due entry" "out=$out"
    end
end

function test_check_warning
    set --local warning (__test_future_date 3)
    __test_write_registry '{"wrn":{"service":"s","name":"Warning Token","pass_path":"dev/w","env_var":"W","scopes":"","expires":"'$warning'","renew_url":"","login_cmd":""}}'

    set --local out (__test_strip_color (pat check 2>&1))
    if string match --quiet '*expires in*' "$out"
        __test_pass "check: shows warning for entry expiring in 3 days"
    else
        __test_fail "check: shows warning for entry expiring in 3 days" "out=$out"
    end
end

function test_check_ok_suppressed
    set --local ok (__test_future_date 60)
    __test_write_registry '{"good":{"service":"s","name":"Good Token","pass_path":"dev/g","env_var":"G","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'

    set --local out (pat check 2>&1)
    if test -z "$out"
        __test_pass "check: OK entries produce no output"
    else
        __test_fail "check: OK entries produce no output" "out=$out"
    end
end

function test_check_missing_registry
    rm --force $TMPDIR/pats.json
    set --local out (pat check 2>&1)
    set --local code $status
    if test $code -eq 0; and test -z "$out"
        __test_pass "check: missing registry is graceful (no output, exit 0)"
    else
        __test_fail "check: missing registry is graceful (no output, exit 0)" "exit=$code out=$out"
    end
end

function test_export_valid
    set --local ok (__test_future_date 60)
    __test_write_registry '{"ghcr":{"service":"ghcr.io","name":"GHCR","pass_path":"dev/ghcr-token","env_var":"GITHUB_TOKEN","scopes":"read:packages","expires":"'$ok'","renew_url":"","login_cmd":""}}'
    __test_write_pass dev/ghcr-token "ghp_test_token_123"

    set --local out (pat export ghcr 2>&1)
    set --local code $status

    if test $code -eq 0; and test "$GITHUB_TOKEN" = "ghp_test_token_123"
        __test_pass "export: sets env var from pass"
    else
        __test_fail "export: sets env var from pass" "exit=$code GITHUB_TOKEN=$GITHUB_TOKEN out=$out"
    end
    set --erase GITHUB_TOKEN
end

function test_export_no_name
    set --local out (pat export 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*Usage*' "$out"
        __test_pass "export: no name shows usage"
    else
        __test_fail "export: no name shows usage" "exit=$code out=$out"
    end
end

function test_export_nonexistent
    set --local ok (__test_future_date 60)
    __test_write_registry '{"real":{"service":"s","name":"N","pass_path":"dev/r","env_var":"R","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'

    set --local out (pat export nonexistent 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*unknown entry*' "$out"
        __test_pass "export: nonexistent key returns error"
    else
        __test_fail "export: nonexistent key returns error" "exit=$code out=$out"
    end
end

function test_export_null_env_var
    set --local ok (__test_future_date 60)
    __test_write_registry '{"noenv":{"service":"s","name":"N","pass_path":"dev/n","env_var":null,"scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'

    set --local out (pat export noenv 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*no env_var configured*' "$out"
        __test_pass "export: null env_var returns error"
    else
        __test_fail "export: null env_var returns error" "exit=$code out=$out"
    end
end

function test_export_pass_fails
    set --local ok (__test_future_date 60)
    __test_write_registry '{"nopas":{"service":"s","name":"N","pass_path":"dev/missing","env_var":"MISS_TOK","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'
    # Don't create the pass file — mock will fail

    set --local out (pat export nopas 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*failed to retrieve*' "$out"
        __test_pass "export: missing pass entry returns error"
    else
        __test_fail "export: missing pass entry returns error" "exit=$code out=$out"
    end
end

function test_login_valid
    set --local ok (__test_future_date 60)
    __test_write_registry '{"lgn":{"service":"s","name":"Login Test","pass_path":"dev/lgn","env_var":"LGN_TOK","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":"echo login_success"}}'
    __test_write_pass dev/lgn "tok123"

    set --local out (pat login lgn 2>&1)
    set --local code $status
    if test $code -eq 0; and string match --quiet '*login_success*' "$out"
        __test_pass "login: runs login_cmd after export"
    else
        __test_fail "login: runs login_cmd after export" "exit=$code out=$out"
    end
    set --erase LGN_TOK
end

function test_login_no_name
    set --local out (pat login 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*Usage*' "$out"
        __test_pass "login: no name shows usage"
    else
        __test_fail "login: no name shows usage" "exit=$code out=$out"
    end
end

function test_login_null_cmd
    set --local ok (__test_future_date 60)
    __test_write_registry '{"nocmd":{"service":"s","name":"N","pass_path":"dev/nc","env_var":"NC_TOK","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":null}}'
    __test_write_pass dev/nc "tok"

    set --local out (pat login nocmd 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*no login_cmd*' "$out"
        __test_pass "login: null login_cmd returns error"
    else
        __test_fail "login: null login_cmd returns error" "exit=$code out=$out"
    end
    set --erase NC_TOK
end

function test_add_valid
    __test_write_registry '{}'

    # Feed all prompts via pipe: service, name, pass_path, env_var, scopes, expires, renew_url, login_cmd, token
    printf 'ghcr.io\nGHCR\ndev/ghcr-add\nGH_ADD_TOK\nread:packages\n2027-06-15\nhttps://github.com/settings/tokens\necho ok\nsecret_add_tok\n' | pat add testpat 2>&1
    set --local code $status

    # Check registry was updated
    set --local svc (jq --raw-output '.testpat.service' $TMPDIR/pats.json)
    # Check pass file was created
    set --local stored (cat $TMPDIR/pass/dev/ghcr-add 2>/dev/null)

    if test $code -eq 0; and test "$svc" = "ghcr.io"; and test "$stored" = "secret_add_tok"
        __test_pass "add: creates registry entry and stores token in pass"
    else
        __test_fail "add: creates registry entry and stores token in pass" "exit=$code svc=$svc stored=$stored"
    end
end

function test_add_no_name
    set --local out (pat add 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*Usage*' "$out"
        __test_pass "add: no name shows usage"
    else
        __test_fail "add: no name shows usage" "exit=$code out=$out"
    end
end

function test_add_invalid_date
    __test_write_registry '{}'

    # Feed prompts with invalid date (6th field)
    printf 'svc\nname\ndev/bad\nBAD_TOK\nscopes\n2026-13-99\n\n\ntok\n' | pat add baddate 2>&1
    set --local code $status

    if test $code -eq 1
        __test_pass "add: invalid date format returns error"
    else
        __test_fail "add: invalid date format returns error" "exit=$code"
    end
end

function test_renew_update_date
    set --local old_date (__test_future_date 10)
    __test_write_registry '{"rnw":{"service":"s","name":"Renew Test","pass_path":"dev/rnw","env_var":"RNW","scopes":"","expires":"'$old_date'","renew_url":"","login_cmd":""}}'
    __test_write_pass dev/rnw "old_token"

    # Skip token (empty line), provide new date
    printf '\n2028-01-15\n' | pat renew rnw >/dev/null 2>&1
    set --local code $status

    set --local new_date (jq --raw-output '.rnw.expires' $TMPDIR/pats.json)
    if test "$new_date" = "2028-01-15"
        __test_pass "renew: updates expiry date in registry"
    else
        __test_fail "renew: updates expiry date in registry" "new_date=$new_date"
    end
end

function test_renew_update_token
    set --local ok (__test_future_date 60)
    __test_write_registry '{"rnw2":{"service":"s","name":"Renew Token","pass_path":"dev/rnw2","env_var":"RNW2","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'
    __test_write_pass dev/rnw2 "old_token"

    # Provide new token, skip date (empty line)
    printf 'new_secret_token\n\n' | pat renew rnw2 >/dev/null 2>&1

    set --local stored (cat $TMPDIR/pass/dev/rnw2)
    if test "$stored" = "new_secret_token"
        __test_pass "renew: updates token in pass"
    else
        __test_fail "renew: updates token in pass" "stored=$stored"
    end
end

function test_renew_opens_url
    set --local ok (__test_future_date 60)
    __test_write_registry '{"rnw3":{"service":"s","name":"URL Test","pass_path":"dev/rnw3","env_var":"RNW3","scopes":"","expires":"'$ok'","renew_url":"https://example.com/renew","login_cmd":""}}'
    __test_write_pass dev/rnw3 "tok"

    rm --force $TMPDIR/opened_url
    printf '\n\n' | pat renew rnw3 >/dev/null 2>&1

    if test -f $TMPDIR/opened_url
        set --local url (cat $TMPDIR/opened_url)
        if test "$url" = "https://example.com/renew"
            __test_pass "renew: opens renew_url via xdg-open"
        else
            __test_fail "renew: opens renew_url via xdg-open" "url=$url"
        end
    else
        __test_fail "renew: opens renew_url via xdg-open" "xdg-open not called"
    end
end

function test_renew_no_name
    set --local ok (__test_future_date 60)
    __test_write_registry '{"x":{"service":"s","name":"N","pass_path":"dev/x","env_var":"X","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'

    set --local out (pat renew 2>&1)
    set --local code $status
    if test $code -eq 1; and string match --quiet '*Usage*' "$out"
        __test_pass "renew: no name shows usage"
    else
        __test_fail "renew: no name shows usage" "exit=$code out=$out"
    end
end

function test_renew_invalid_date
    set --local ok (__test_future_date 60)
    __test_write_registry '{"rnv":{"service":"s","name":"N","pass_path":"dev/rnv","env_var":"RNV","scopes":"","expires":"'$ok'","renew_url":"","login_cmd":""}}'
    __test_write_pass dev/rnv "tok"

    # Skip token, provide bad date
    printf '\nbaddate\n' | pat renew rnv 2>&1
    set --local code $status

    if test $code -eq 1
        __test_pass "renew: invalid date format returns error"
    else
        __test_fail "renew: invalid date format returns error" "exit=$code"
    end
end

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

echo "=== pat function tests ==="
echo ""

__test_setup

# Re-override __pat_registry_path after any source calls
function __pat_registry_path
    echo $TMPDIR/pats.json
end

# Help tests
test_help_no_args
test_help_flag
test_help_h_flag
test_unknown_command

# Dependency tests
test_deps_missing_jq
# Re-override after dep test restores from source
function __pat_registry_path; echo $TMPDIR/pats.json; end
test_deps_missing_pass
function __pat_registry_path; echo $TMPDIR/pats.json; end

# List tests
test_list_empty_registry
test_list_missing_registry
test_list_valid_entries
test_list_ls_alias

# Check tests
test_check_empty_registry
test_check_expired
test_check_warning
test_check_ok_suppressed
test_check_missing_registry

# Export tests
test_export_valid
test_export_no_name
test_export_nonexistent
test_export_null_env_var
test_export_pass_fails

# Login tests
test_login_valid
test_login_no_name
test_login_null_cmd

# Add tests
test_add_valid
test_add_no_name
test_add_invalid_date

# Renew tests
test_renew_update_date
test_renew_update_token
test_renew_opens_url
test_renew_no_name
test_renew_invalid_date

echo ""
echo "=== Results: $__test_passed passed, $__test_failed failed ==="

__test_teardown

if test $__test_failed -gt 0
    exit 1
end
