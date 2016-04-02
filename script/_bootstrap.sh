#
# [bootstrap] prepare system for provisioning (to be sourced, do not use directly)
#
: ${DEPLOY_ENV:='local'}

declare -r LINUX_DISTRO=$(cat /etc/issue.net | cut -d ' ' -f 1)
declare -r MACHINE_TYPE=$(sudo dmidecode -t system | egrep "^\s*Family: " | sed 's/^.*: //')

function die() {
  echo "[BOOTSTRAP ERROR] ${@}"
  exit 1
}

function install_ansible() {
  sudo apt-get -y install software-properties-common
  sudo apt-add-repository -y ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get -y install ansible
}

function install_ruby() {
  sudo apt-get -y install ruby
}

if [[ "${DEPLOY_ENV}" == "local" ]]; then
  [[ -x "$(which apt-get)" ]] || die 'Apt-Get executable not found!'
  [[ "${LINUX_DISTRO}" == "Ubuntu" ]] || die 'Only supported distro is Ubuntu, sorry ;('
  [[ "${MACHINE_TYPE}" == "Virtual Machine" ]] || die 'Should be deployed only on virtual machines!'

  sudo apt-get update

  [[ -x "$(which ansible)" ]] || install_ansible
  [[ -x "$(which ruby)" ]] || install_ruby
else
  [[ -x "$(which ruby)" ]] || die 'Ruby executable not found!'
  [[ -x "$(which ansible)" ]] || die 'Ansible executable not found!'
fi
