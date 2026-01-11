#!/bin/bash
# Flam3 Palette Utility - List and apply palettes to genomes
# Usage:
#   flam3-palette-util.sh list              - List all available palette names
#   flam3-palette-util.sh apply <name> <genome_file>  - Apply palette to genome

PALETTES_FILE="/usr/share/flam3/flam3-palettes.xml"

list_palettes() {
    grep 'name="' "$PALETTES_FILE" | sed 's/.*name="\([^"]*\)".*/\1/' | sort -u
}

apply_palette() {
    local palette_name="$1"
    local genome_file="$2"

    if [ ! -f "$genome_file" ]; then
        echo "Error: Genome file not found: $genome_file" >&2
        exit 1
    fi

    # Extract palette data from palettes file (data spans multiple lines)
    # Use awk to extract everything between data=" and "/>
    local palette_data
    palette_data=$(awk -v name="$palette_name" '
        $0 ~ "name=\"" name "\"" {
            # Found the palette, start capturing
            match($0, /data="/)
            data = substr($0, RSTART + 6)
            while (data !~ /"/) {
                getline
                data = data $0
            }
            sub(/".*/, "", data)
            gsub(/[[:space:]]/, "", data)
            print data
            exit
        }
    ' "$PALETTES_FILE")

    if [ -z "$palette_data" ]; then
        echo "Error: Palette not found: $palette_name" >&2
        exit 1
    fi

    # Remove existing color entries from genome
    sed -i '/<color index=/d' "$genome_file"

    # Parse palette data and insert color entries before </flame>
    # Each color is 8 hex chars: 00RRGGBB (first 00 is unused)
    local color_entries=""
    local index=0
    local data="${palette_data//[[:space:]]/}"  # Remove whitespace

    while [ ${#data} -ge 8 ]; do
        local hex="${data:0:8}"
        local r=$((16#${hex:2:2}))
        local g=$((16#${hex:4:2}))
        local b=$((16#${hex:6:2}))
        color_entries+="   <color index=\"$index\" rgb=\"$r $g $b\"/>\n"
        data="${data:8}"
        ((index++))
    done

    # Insert colors before </flame>
    sed -i "s|</flame>|$color_entries</flame>|" "$genome_file"

    echo "Applied palette '$palette_name' with $index colors"
}

# Curated list of visually interesting palettes for quick selection
curated_palettes() {
    cat << 'EOF'
Autumn_Leaves
Autumn_Mountains
Autumn_Garden
Blue_Velvet
Bluebells
Blush
Carnival
Cherry
Canyon
Coral
Cotton_Flower
Creamsicle
Dark_Rainbow
Dark_Rose
Dark_Turquoise
Dark_Waters
Dragon
Dynasty
Embers
Evening_Sunshine
Explosion
fire-dragon
Fiery_Sky
Fiesta
First_Love
Flame
Foamy_Waves
Forest
Frivolous
Glade
Glory
Gold_and_Blue
Golden
Golden_Green
Goldenrod
Grape
ice-dragon
Lemon_Grass
Magenta_and_Teal
Mahogany
Marina
Meadow
Mermaid
Mesmerize
Midnight_Wave
Mint
Mistic
Mixed_Berry
Morning_Glories_at_Night
Moss
Mystery
Neon
Neon_Purple
Night_Flower
Night_Reeds
Ocean_Mist
Parrot
Peace
Persia
Pink
Pollen
Poppies
Purple
Queen_Anne
Rainbow_Sprinkles
Rainforest
Rainy_Day_in_Spring
Red_Light
Riddle
Riverside
Rose_Bush
Rusted
Sachet
Sage
Sea_Mist
Secret
Serenity
Serpent
Singe
Slate
Soap_Bubble
Sophia
Strawberries
Summer
Summer_Fire
Summer_Skies
Summer_Tulips
Sunbathing
Sunset
Surfer
Tequila
Thistle
Tribal
Trippy
Tropic
Tryst
Tumbleweed
Underwater_Day
Venice
Victoria
Violet
Violet_Fog
Watermelon
Whisper
Wintergrass
Woodland
Yellow_Silk
Zinfandel
EOF
}

# Get palette colors for preview (8 evenly spaced colors as hex)
get_palette_colors() {
    local palette_name="$1"

    # Extract full palette data using awk (handles multiline)
    local palette_data
    palette_data=$(awk -v name="$palette_name" '
        $0 ~ "name=\"" name "\"" {
            match($0, /data="/)
            data = substr($0, RSTART + 6)
            while (data !~ /"/) {
                getline
                data = data $0
            }
            sub(/".*/, "", data)
            gsub(/[[:space:]]/, "", data)
            print data
            exit
        }
    ' "$PALETTES_FILE")

    if [ -z "$palette_data" ]; then
        echo ""
        return
    fi

    # Extract 8 evenly spaced colors across the 256-color palette
    local colors=""
    local len=${#palette_data}
    local step=$((len / 8 / 8 * 8))  # Step in 8-char chunks

    for i in 0 1 2 3 4 5 6 7; do
        local pos=$((i * step))
        if [ $pos -lt $len ]; then
            local hex="${palette_data:$pos:8}"
            # Format as #RRGGBB (skip first 2 chars which are 00)
            colors+="#${hex:2:6},"
        fi
    done

    # Remove trailing comma
    echo "${colors%,}"
}

# Output curated palettes with color previews
curated_with_colors() {
    while IFS= read -r name; do
        local colors=$(get_palette_colors "$name")
        echo "$name|$colors"
    done < <(curated_palettes)
}

case "$1" in
    list)
        list_palettes
        ;;
    curated)
        curated_palettes
        ;;
    curated-colors)
        curated_with_colors
        ;;
    apply)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 apply <palette_name> <genome_file>" >&2
            exit 1
        fi
        apply_palette "$2" "$3"
        ;;
    *)
        echo "Flam3 Palette Utility"
        echo "Usage:"
        echo "  $0 list              - List all available palettes"
        echo "  $0 curated           - List curated palettes for quick selection"
        echo "  $0 apply <name> <file> - Apply palette to genome file"
        ;;
esac
