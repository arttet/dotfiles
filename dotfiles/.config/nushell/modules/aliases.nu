# Compact aliases shared with the other interactive shells where practical.

export alias .. = cd ..
export alias ... = cd ../..
export alias .... = cd ../../..
export alias _ = cd -
export alias - = cd -

export alias n = nvim
export alias m = mise
export alias j = just

export alias cb = cargo build
export alias cbr = cargo build --release
export alias cr = cargo run
export alias crr = cargo run --release
export alias ct = cargo test
export alias cc = cargo check
export alias cf = cargo fmt
export alias ca = cargo add
export alias caa = cargo add --dev
export alias cdoc = cargo doc --open

export alias nb = npm run build
export alias ns = npm start
export alias nt = npm test
export alias ni = npm install

export alias pi = pip install
export alias pu = pip uninstall
export alias pl = pip list
export alias pf = pip install -e .

export def --wrapped ls [...args] {
  ^eza --icons ...$args
}
