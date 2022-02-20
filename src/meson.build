conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', meson.project_version())
conf_data.set('PKG_DATA_DIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))
conf_data.set('LIBRETRO_CORE_DIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name(), 'libretro', 'cores'))
conf_data.set('ROM_DIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name(), 'roms'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

application_files = files(
    join_paths('Layouts', 'EmulatorLayout.vala'),
    join_paths('Layouts', 'MainLayout.vala'),
    join_paths('Models', 'LibretroCore.vala'),
    join_paths('Models', 'LibretroCoreInfo.vala'),
    join_paths('Services', 'CoreManager.vala'),
    join_paths('Services', 'CoreRepository.vala'),
    join_paths('Services', 'Emulator.vala'),
    join_paths('Services', 'EmulatorManager.vala'),
    join_paths('Services', 'SQLClient.vala'),
    join_paths('Widgets', 'EmulatorHeaderBar.vala'),
    join_paths('Widgets', 'MainHeaderBar.vala'),
    join_paths('Windows', 'EmulatorWindow.vala'),
    join_paths('Windows', 'MainWindow.vala'),
    join_paths('Application.vala')
)

# This won't be necessary in future versions of retro-gtk
c_args = [
    '-DRETRO_GTK_USE_UNSTABLE_API'
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    application_id,
    application_files,
    config_header,
    # css_gresource,
    c_args: c_args,
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.24.20'),
        dependency('gee-0.8', version: '>= 0.20.3'),
        dependency('glib-2.0', version: '>= 2.64.6'),
        dependency('granite', version: '>= 6.2.0'),
        dependency('libhandy-1', version: '>= 1.2.0'),
        # dependency('retro-gtk-0.14')
        dependency('retro-gtk-1', version: '>= 1.0.2'),
        dependency('sqlite3', version: '>= 3.31.1')
    ],
    vala_args: vala_args,
    install: true
)
