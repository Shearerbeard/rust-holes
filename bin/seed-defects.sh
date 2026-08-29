#!/usr/bin/env bash
# Seed each defect class in a throwaway copy of the worktree and assert
# bin/check exits nonzero, naming the rule. One ok-case proves a benign
# edit still passes. Usage, from the repo root: bin/seed-defects.sh .
# The sed -i '' calls assume BSD sed (macOS); on GNU sed, drop the ''.
set -u
SRC="$1"; TMP=$(mktemp -d); pass=0; fail=0
run_ok_case() { # name, setup-command: must still exit 0
  local name="$1"; shift
  rm -rf "$TMP/c"; cp -R "$SRC" "$TMP/c"; rm -rf "$TMP/c/.git"
  ( cd "$TMP/c" && eval "$*" ) >/dev/null 2>&1
  out=$(cd "$TMP/c" && bin/check 2>&1); rc=$?
  if [ $rc -eq 0 ]; then echo "PASS ok-case:$name -> exit 0"; pass=$((pass+1));
  else echo "MISS ok-case:$name -> exit $rc (false failure: $(echo "$out" | head -1))"; fail=$((fail+1)); fi
}
run_case() { # name, rule, setup-command
  local name="$1"; local rule="$2"; shift 2
  rm -rf "$TMP/c"; cp -R "$SRC" "$TMP/c"; rm -rf "$TMP/c/.git"
  ( cd "$TMP/c" && eval "$*" ) >/dev/null 2>&1
  out=$(cd "$TMP/c" && bin/check 2>&1); rc=$?
  if [ $rc -ne 0 ] && echo "$out" | grep -q "FAIL $rule:"; then echo "PASS seeded:$name -> exit $rc: $(echo "$out" | grep "FAIL $rule:" | head -1)"; pass=$((pass+1));
  else echo "MISS seeded:$name -> exit $rc (expected nonzero with a FAIL $rule line; got: $(echo "$out" | head -2 | tr "\n" " "))"; fail=$((fail+1)); fi
}
run_case dangling-link links "printf '\nSee [x](templates/does-not-exist.md).\n' >> README.md"
run_case half-filled-template template-header "sed -i '' '1,12s/Template\./Copy./' templates/DESIGN.md"
run_case missing-read-order-row readme-read-order "sed -i '' '/templates\/MANIFEST.md/d' README.md"
run_case stripped-private-header never-publish "sed -i '' 's/^\*\*Private\.\*\*/Public./' README.md"
run_case stripped-stamp-line template-stamp "sed -i '' 's/copied from rust-holes@/xx/' templates/MANIFEST.md"
run_case same-dir-dangling-link links "printf '\\nSee [plan](nope.md).\\n' >> docs/plans/2026-08-25-cleanup-execution.md"
run_case truncated-opening-paragraph template-header "python3 -c \"import pathlib;p=pathlib.Path('templates/DESIGN.md');t=p.read_text().split('\\n');p.write_text('\\n'.join(t[:2]+['']+t[3:]))\""
run_case partial-stamp-token template-stamp "sed -i '' 's/is this repo.s HEAD at copy time\\./is HEAD./' templates/DESIGN.md"
run_case private-moved-down never-publish "python3 -c \"import pathlib;p=pathlib.Path('README.md');t=p.read_text();p.write_text(t.replace('**Private.**','Note.',1)+'\\n**Private.** later.\\n')\""
run_case readme-substring-match readme-read-order "sed -i '' 's/| \`templates\/MANIFEST.md\` |/| \`templates\/MANIFEST-old.md\` |/' README.md; printf '\\nSee templates/MANIFEST.md in prose.\\n' >> README.md"
run_case angle-link-with-title links "printf '\\nSee [x](<nope.md> \"title\").\\n' >> docs/plans/2026-08-25-cleanup-execution.md"
run_case row-moved-to-other-table readme-read-order "python3 -c \"import pathlib;p=pathlib.Path('README.md');t=p.read_text();row=[l for l in t.splitlines() if 'templates/MANIFEST.md' in l][0];t=t.replace(row+chr(10),'');p.write_text(t+chr(10)+'## Other'+chr(10)+chr(10)+'| File | x |'+chr(10)+'|---|---|'+chr(10)+row+chr(10))\""
run_case h1-merged-paragraph template-stamp "python3 -c \"import pathlib;p=pathlib.Path('templates/DESIGN.md');t=p.read_text().split(chr(10));p.write_text(chr(10).join([t[0]]+['Template. Stray line.']+t[1:]))\""
run_case nested-template-unstamped template-stamp "mkdir -p templates/sub; printf '# Sub\\n\\nTemplate. No stamp here.\\n' > templates/sub/x.md"
run_case second-table-same-section readme-read-order "python3 -c \"import pathlib;p=pathlib.Path('README.md');t=p.read_text();row=[l for l in t.splitlines() if 'templates/MANIFEST.md' in l][0];t=t.replace(row+chr(10),'');t=t.replace('## Using it', '| File | x |'+chr(10)+'|---|---|'+chr(10)+row+chr(10)+chr(10)+'## Using it');p.write_text(t)\""
run_ok_case hashtag-line-in-paragraph "python3 -c \"import pathlib;p=pathlib.Path('templates/DESIGN.md');t=p.read_text().split(chr(10));t.insert(3,'#tag continues the paragraph');p.write_text(chr(10).join(t))\""
run_case tab-heading-before-stamp template-stamp "python3 -c \"import pathlib;p=pathlib.Path('templates/DESIGN.md');t=p.read_text().split(chr(10));t.insert(2,'##'+chr(9)+'Heading');t.insert(3,'');p.write_text(chr(10).join(t))\""
run_case bare-heading-before-stamp template-stamp "python3 -c \"import pathlib;p=pathlib.Path('templates/DESIGN.md');t=p.read_text().split(chr(10));t.insert(2,'##');t.insert(3,'');p.write_text(chr(10).join(t))\""
echo "baseline:"; (cd "$SRC" && bin/check && echo "PASS baseline exit 0") || echo "MISS baseline nonzero"
echo "seeded: $pass pass, $fail miss"; rm -rf "$TMP"; [ $fail -eq 0 ]
