cmake_minimum_required(VERSION 2.8.3)
project(git-bash-aliases)

install(
  FILES
  git-bash-aliases.bash
  DESTINATION /etc/bash_completion.d/
  )

set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "bash-completion")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Short aliases for commonly used git commands.")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Ryan Sinnet <ryan@rwsinnet.com>")
set(CPACK_SYSTEM_NAME "linux-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
set(CPACK_PACKAGE_VERSION 0.0.0)

include(CPack)
