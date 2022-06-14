# Project name and programming language
project('com.github.avojak.replay', 'vala', 'c', version: '1.0.0')

i18n = import('i18n')
gnome = import('gnome')

valac = meson.get_compiler ('vala')

vala_args = ['--pkg', 'posix']

application_id = meson.project_name()
application_name = 'Replay'

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

# Set out log domain
add_project_arguments('-DG_LOG_DOMAIN="@0@"'.format(meson.project_name()), language: 'c')

subdir('data')
subdir('src')
# subdir('test')
subdir('po')

meson.add_install_script('meson/post_install.py')
