function ls --wraps='exa --long --color=auto' --description 'alias ls=exa --long --color=auto'
  exa --long --color=auto $argv; 
end
