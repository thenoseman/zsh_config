_npm_run_scripts () {
    compls=$(jq -r ".scripts | keys[]" package.json)
    completions=(${=compls})
    compadd -- $completions
}

compdef _npm_run_scripts npm run
