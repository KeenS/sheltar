#!/bin/sh
# Copyright (c) 2015, Sunrin SHIMURA
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the　names of its contributors 
#   may be used to endorse or promote products derived from this software 
#   without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Sunrin SHIMURA BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SHELTAR="../sheltar"
BACKUP_DIR=backup
BACKUP_LIST_FILE=list.txt
BACKUP_FILES="a.txt b/1.txt b/2.txt c/1.txt c/2.txt d/e/f.txt"

testBaseBackup(){
    ${SHELTAR} backup "${BACKUP_DIR}" "${BACKUP_LIST_FILE}"
    assertEquals "Backup file should be created" \
                 1 "$(ls "${BACKUP_DIR}" | wc -l | tr -d '[ \t\n]' )"
    assertEquals "Backup file should contain all the listed file" \
    "$({ echo "${BACKUP_FILES}"; echo c/; } | tr \  \\n | sort)" "$(tar tJf ${BACKUP_DIR}/$(ls ${BACKUP_DIR}) | sort)"
}


testIncrementalBackup(){
    # need to seelp to shift mtime
    sleep 1
    echo aaa >> a.txt
    ${SHELTAR} backup "${BACKUP_DIR}" "${BACKUP_LIST_FILE}"
    assertEquals "New backup file should be created" \
                 2 "$(ls "${BACKUP_DIR}" | wc -l | tr -d '[ \t\n]' )"
    assertEquals "Incremental backup file should contain only newly modified files" \
    a.txt "$(tar tJf ${BACKUP_DIR}/$(ls -t ${BACKUP_DIR} | head -n 1))"
}

testIncrementalBackupDir(){
    # need to seelp to shift mtime
    sleep 1
    echo bbb >> b/1.txt
    echo ccc >> c/1.txt
    ${SHELTAR} backup "${BACKUP_DIR}" "${BACKUP_LIST_FILE}"
    assertEquals "New backup file should be created" \
                 3 "$(ls "${BACKUP_DIR}" | wc -l | tr -d '[ \t\n]' )"

    assertEquals "Incremental backup file should contain only newly modified files.
Concerning directory, files under directory which ends with '/' in list file should separately managed.
directory which ends without '/' in list file should be managed as one dir
" \
    "b/1.txt" "$(tar tJf ${BACKUP_DIR}/$(ls -t ${BACKUP_DIR} | head -n 1 | sort ))"
}


testExtractOne(){
    rm -rf $BACKUP_FILES
    ${SHELTAR} extract "${BACKUP_DIR}" a.txt
    assertTrue "a.txt should be restored" "[ -s a.txt ]"
    assertEquals "The content of a.txt should be 'aaa'" \
    "aaa" "$(cat a.txt)"
}

testExtractAll(){
    rm -rf $BACKUP_FILES
    sleep 1
    ${SHELTAR} extract "${BACKUP_DIR}"
    assertTrue "a.txt should exist" "[ -s a.txt ]"
    assertTrue "b/1.txt should exist" "[ -e b/1.txt ]"
    assertTrue "b/2.txt should exist" "[ -e b/2.txt ]"
    assertTrue "c/1.txt should exist" "[ -e c/1.txt ]"
    assertTrue "c/2.txt should exist" "[ -e c/2.txt ]"
    assertTrue "d/e/f.txt should exist" "[ -e d/e/f.txt ]"
}

oneTimeSetUp(){
    mkdir -p b c d/e ${BACKUP_DIR}

    for FILE in $BACKUP_FILES
    do
        touch "${FILE}"
    done

    cat <<EOF > "${BACKUP_LIST_FILE}"
a.txt
b/
c
d/
EOF
}

oneTimeTearDown(){
    rm -rf ${BACKUP_DIR} ${BACKUP_FILES} ${BACKUP_LIST_FILE}
    rm -rf b c d 
}

. shunit2-2.1.6/src/shunit2
