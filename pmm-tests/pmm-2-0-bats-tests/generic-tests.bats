## Generic bats tests

function checkZipFileContents(){
    ZIP_FILE_NAME=$(echo "${lines[-1]}" | awk '{ print $1 }')
    run unzip -l "$ZIP_FILE_NAME"
}

@test "run pmm-admin under regular(non-root) user privileges" {
if [[ $(id -u) -eq 0 ]] ; then
        skip "Skipping this test, because you are running under root"
fi
run pmm-admin
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin [<flags>] <command> [<args> ...]" ]
}

@test "run pmm-admin under root privileges" {
if [[ $(id -u) -ne 0 ]] ; then
        skip "Skipping this test, because you are NOT running under root"
fi
run pmm-admin
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin [<flags>] <command> [<args> ...]" ]
}

@test "run pmm-admin without any arguments" {
run pmm-admin
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin [<flags>] <command> [<args> ...]" ]
}

@test "run pmm-admin help" {
run pmm-admin help
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin [<flags>] <command> [<args> ...]" ]
}

@test "run pmm-admin -h" {
run pmm-admin -h
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin [<flags>] <command> [<args> ...]" ]
}

@test "run pmm-admin with wrong option" {
run pmm-admin install
echo "$output"
    [ "$status" -eq 1 ]
    echo "${output}" | grep "pmm-admin: error: expected command but got"
}

@test "run pmm-admin list to check for available services" {
run pmm-admin list
echo "$output"
    [ "$status" -eq 0 ]
}

@test "run pmm-admin --version" {
 run pmm-admin --version
 echo "$output"
 	[ "$status" -eq 0 ]
	echo "$output" | grep "Version: 2.2"
}

@test "run pmm-admin config without parameters" {
run pmm-admin config
echo "$output"
	[ "$status" -eq 1 ]
	echo "${output}" | grep "Failed to register pmm-agent on PMM Server: Node with name"
}

@test "run pmm-admin summary --help" {
run pmm-admin summary --help
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin summary [<flags>]" ]
}

@test "run pmm-admin summary -h" {
run pmm-admin summary -h
echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "usage: pmm-admin summary [<flags>]" ]
}

@test "run pmm-admin summary --version" {
run pmm-admin summary --version
echo "$output"
    [ "$status" -eq 0 ]
    echo "$output" | grep "Version: 2.2"
}

@test "run pmm-admin summary --server-url with http" {
run pmm-admin summary --server-url='http://admin:admin@localhost'
echo "$output"
    [ "$status" -eq 0 ]
    echo "$output" | grep ".zip created."
    checkZipFileContents
    echo "$output" | grep "34 files"
}

@test "run pmm-admin summary --server-url with https and verify warning" {
run pmm-admin summary --server-url='https://admin:admin@localhost'
echo "$output"
    [ "$status" -eq 0 ]
    echo "$output" | grep "certificate is not valid for any names"
    echo "${lines[1]}" | grep ".zip created."
}

@test "run pmm-admin summary --server-url --server-insecure-tls with https" {
run pmm-admin summary --server-url='https://admin:admin@localhost' --server-insecure-tls
echo "$output"
    [ "$status" -eq 0 ]
    echo "${lines[0]}" | grep ".zip created."
    checkZipFileContents
    echo "$output" | grep "34 files"
}

@test "run pmm-admin summary --debug" {
run pmm-admin summary --debug
echo "$output"
    [ "$status" -eq 0 ]
    echo "$output" | grep "POST /v1/inventory/Services/List HTTP/1.1"
    echo "$output" | grep "POST /v1/inventory/Agents/List HTTP/1.1"
    echo "${lines[-1]}" | grep ".zip created."
    checkZipFileContents
    echo "$output" | grep "34 files"
}

@test "run pmm-admin summary --trace" {
run pmm-admin summary --trace
echo "$output"
    [ "$status" -eq 0 ]
    echo "$output" | grep "(*Runtime).Submit() POST /v1/inventory/Services/List HTTP/1.1"
    echo "$output" | grep "(*Runtime).Submit() POST /v1/inventory/Agents/List HTTP/1.1"
    echo "${lines[-1]}" | grep ".zip created."
    checkZipFileContents
    echo "$output" | grep "34 files"
}

function teardown() {
        echo "$output"
}
