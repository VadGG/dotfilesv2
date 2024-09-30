if command -v bat &> /dev/null; then
  alias cat='bat'
# else
#   echo "bat is not installed. Using default cat."
fi

# Check if lsd is installed, then alias ls to lsd
if command -v lsd &> /dev/null; then
  alias ls='lsd'
# else
#   echo "lsd is not installed. Using default ls."
fi

alias ll='ls -al'

if command -v kubectl &> /dev/null; then
  alias k='kubectl'
  alias kp='kubectl get pods'
  alias kn='kubectl get nodes'
# else
#   echo "kubectl is not installed. Using default ls."
fi

if command -v helm &> /dev/null; then
  alias helm-images-find="helm template . | yq '..|.image? | select(.)' | sort -u"
fi
