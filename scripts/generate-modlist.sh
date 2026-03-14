#!/bin/bash

shopt -s nullglob

mkdir -p Modlists
mkdir -p .tmp_modlist

versions=()

for dir in Packwiz/*; do
    VERSION=$(basename "$dir")
    versions+=("$VERSION")

    OUTPUT="Modlists/$VERSION.md"
    TMPFILE=".tmp_modlist/$VERSION.txt"

    > "$TMPFILE"

    cat > "$OUTPUT" <<EOF
# Mods for Minecraft $VERSION

The selected mods are inspired, but not limited by the list of OptiFine alternatives. The modpack also improves the default settings.

| Mod | Source | Project ID |
|-----|---------------------|------------|
EOF

    for file in "$dir"/mods/*.pw.toml; do
        MOD=$(grep '^name' "$file" | cut -d '"' -f2)
        echo "$MOD" >> "$TMPFILE"

        if grep -q "\[update.modrinth\]" "$file"; then
            SOURCE="Modrinth"
            ID=$(grep 'mod-id' "$file" | cut -d '"' -f2)
            LINK="https://modrinth.com/mod/$ID"
        elif grep -q "\[update.curseforge\]" "$file"; then
            SOURCE="CurseForge"
            ID=$(grep 'project-id' "$file" | grep -o '[0-9]*')
            SLUG=$(basename "$file" .pw.toml | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
            LINK="https://www.curseforge.com/minecraft/mc-mods/$SLUG"
        else
            SOURCE="Unknown"
            ID="-"
            LINK="-"
            AUTHORS="Unknown"
        fi

        echo "| [$MOD]($LINK)  | $SOURCE | $ID |" >> "$OUTPUT"
    done
done

cat .tmp_modlist/*.txt | sort | uniq > .tmp_modlist/allmods.txt

COMP="Modlists/COMPARISON-TABLE.md"

cat > "$COMP" <<EOF
# Mod Comparison Between Minecraft Versions

Here you can find the mod comparison table between the currently supported Minecraft versions (may not be accurate for alphas and betas). Some mods have been obsoleted or superseded by better alternatives in the newer versions - see the changelog for full info. You can also find the version-specific mod list by clicking on the version on Modrinth, or by viewing the game version lists in the Modlists folder.

EOF

printf "| Mod " >> "$COMP"
for v in "${versions[@]}"; do
    printf "| %s " "$v" >> "$COMP"
done
printf "|\n" >> "$COMP"

printf "|-----" >> "$COMP"
for v in "${versions[@]}"; do
    printf "|-----" >> "$COMP"
done
printf "|\n" >> "$COMP"

while read mod; do
    printf "| %s " "$mod" >> "$COMP"

    for v in "${versions[@]}"; do
        if grep -qx "$mod" ".tmp_modlist/$v.txt"; then
            printf "| ✔ " >> "$COMP"
        else
            printf "| ❌ " >> "$COMP"
        fi
    done

    printf "|\n" >> "$COMP"
done < .tmp_modlist/allmods.txt

rm -rf .tmp_modlist

echo "Mod lists and comparison table generated successfully."
