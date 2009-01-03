#!/usr/bin/env bash
# File: fill_contributions_macos.sh

# 1. Path to your local repository
REPO_DIR="."
FILE="dummy.txt"

cd "$REPO_DIR" || { echo "Error: Repo not found: $REPO_DIR"; exit 1; }

# 2. Initialize Git if necessary
if [ ! -d .git ]; then
  git init
fi

# 3. Create a dummy file and initial commit
touch "$FILE"
git add "$FILE"
git commit -m "Initial commit to start contribution graph" --quiet

# 4. Set up counters for the progress bar
total_days=365
commits_per_day=25
total_commits=$(( total_days * commits_per_day ))
counter=0

# 5. Function to draw a simple progress bar
progress_bar() {
  local current=$1
  local total=$2
  local width=50  # characters wide
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))
  # build the bar
  printf "\rProgress: ["
  for ((i=0; i<filled; i++)); do printf "#"; done
  for ((i=0; i<empty; i++)); do printf "-"; done
  printf "] %3d%% (%d/%d)" $(( current * 100 / total )) "$current" "$total"
}

# 6. Loop over the past 365 days
for ((d=365; d>=1; d--)); do
  echo "d= $d"
  # Calculate the date 'd' days ago in YYYY-MM-DD
  commit_date=$(date -v -${d}d +%Y-%m-%d)
  
  # 7. Make 10 commits on that date at unique times
  for ((i=1; i<=commits_per_day; i++)); do
    echo "i= $i"
    # Parse the base time and add 'i' minutes to it
    commit_time=$(date -j -f "%Y-%m-%d %H:%M:%S" \
      "${commit_date} 08:00:00" -v+${i}M "+%Y-%m-%dT%H:%M:%S")
    
    # Append a line to the file to have something to commit
    echo "$commit_time - Commit #$i on $commit_date" >> "$FILE"
    git add "$FILE"
    
    # Backdate the commit using environment variables
    GIT_AUTHOR_DATE="$commit_time" \
    GIT_COMMITTER_DATE="$commit_time" \
      git commit -m "Commit at $commit_time" --quiet

    # 8. Update and redraw the progress bar
    ((counter++))
    # progress_bar "$counter" "$total_commits"
  done
done

# 9. Finish with a newline so the shell prompt isn’t on the same line
echo

