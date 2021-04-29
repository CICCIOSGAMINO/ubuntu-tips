##################################################################################################
#                                                                                                #
#                                             ALIASES                                            #
# Here some dedault aliases and the custom alias                                                 #
#                                                                                                #
##################################################################################################
alias l='exa'
alias ll='exa --header --long --extended -l --group --modified --all --git'
alias lll='exa --header --long --extended -l --tree --level=2 --all --git'
alias h='history'

# web aliases
alias pys='python3 -m http.server 8000'
alias html='cp ~/Web/HTML5/template/index.html index.html'
alias speedt='speedtest-cli --simple'

alias gnome-open='evince'

# es module server 
alias serve='web-dev-server --node-resolve --app-index index.html --watch --open'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

##################################################################################################
#                                                                                                #
#                                      Custom FUNCTIONS                                          #
# Functions are more powerful than aliases, you can pass arguments to functions and then short   #
# cut your works !!                                                                              #
#                                                                                                #
##################################################################################################
# custom function 
function httpbin(){
	curl https://httpbin.org/$1
} 
# export -f httpbin

function lint(){
	eslint --env browser,es6 $1
}
# export -f eslint

function youtubemp3(){
	ytdl $1 | ffmpeg -i pipe:0 -b:a 192K -vn $2
}
# export -f youtubemp3

# Copy all the files from ~/Web/LIT/pwa-lite to new folder ($1 pass the name)
# exclude the .git/ folder where the pwa-lite gits are.
function pwa() {
	# cp -r ~/Web/LIT/pwa-lite $1
	rsync -av ~/Web/LIT/pwa-lite/ ./$1 --exclude .git/ --exclude /node_modules --exclude package-lock.json
}
# export -f pwa
