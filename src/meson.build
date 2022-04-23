conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', meson.project_version())
conf_data.set('PKG_DATA_DIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))
conf_data.set('BUNDLED_LIBRETRO_CORE_DIR', join_paths(get_option('prefix'), get_option('libdir'), 'libretro'))
conf_data.set('BUNDLED_ROM_DIR', join_paths(get_option('prefix'), get_option('libdir'), 'roms'))
conf_data.set('SYSTEM_LIBRETRO_CORE_DIR', '/var/run/host/usr/lib/x86_64-linux-gnu/libretro')
conf_data.set('SYSTEM_LIBRETRO_INFO_DIR', '/var/run/host/usr/share/libretro/info')

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

application_files = files(
    join_paths('Core', 'Client.vala'),
    join_paths('Core', 'DatabaseLibretroCoreSource.vala'),
    join_paths('Core', 'FileSystemLibrarySource.vala'),
    join_paths('Core', 'FileSystemLibretroCoreSource.vala'),
    join_paths('Core', 'LibrarySource.vala'),
    join_paths('Core', 'LibretroCoreSource.vala'),
    join_paths('Layouts', 'EmulatorLayout.vala'),
    join_paths('Layouts', 'LibraryLayout.vala'),
    join_paths('Models', 'Game.vala'),
    join_paths('Models', 'LibraryItemFilterFunction.vala'),
    join_paths('Models', 'LibraryItemSortFunction.vala'),
    join_paths('Models', 'LibretroCore.vala'),
    join_paths('Models', 'LibretroCoreInfo.vala'),
    join_paths('Models', 'LibretroGame.vala'),
    join_paths('Models', 'VideoFilterMapping.vala'),
    # join_paths('Models', 'System.vala'),
    join_paths('Services', 'Emulator.vala'),
    join_paths('Services', 'EmulatorManager.vala'),
    join_paths('Services', 'GameLibrary.vala'),
    join_paths('Services', 'LibraryWindowActionManager.vala'),
    join_paths('Services', 'LibretroCoreRepository.vala'),
    join_paths('Services', 'LibretroGameRepository.vala'),
    join_paths('Services', 'SQLClient.vala'),
    join_paths('Utils', 'DigestUtils.vala'),
    join_paths('Utils', 'FileUtils.vala'),
    join_paths('Views', 'Settings', 'AbstractSettingsView.vala'),
    join_paths('Views', 'Settings', 'BehaviorSettingsView.vala'),
    join_paths('Views', 'Settings', 'InterfaceSettingsView.vala'),
    join_paths('Views', 'Settings', 'SystemSettingsPage.vala'),
    join_paths('Views', 'Settings', 'SystemsSettingsView.vala'),
    join_paths('Views', 'GameDetailView.vala'),
    join_paths('Views', 'LibraryAlertView.vala'),
    join_paths('Views', 'LibraryView.vala'),
    join_paths('Views', 'WelcomeView.vala'),
    join_paths('Widgets', 'Dialogs', 'PreferencesDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'LibraryItemPropertiesDialog.vala'),
    join_paths('Widgets', 'EmulatorHeaderBar.vala'),
    join_paths('Widgets', 'GameGrid.vala'),
    join_paths('Widgets', 'GameGridDetailsPanel.vala'),
    join_paths('Widgets', 'LibraryItem.vala'),
    join_paths('Widgets', 'LibrarySidePanel.vala'),
    join_paths('Widgets', 'LibrarySidePanelItem.vala'),
    join_paths('Widgets', 'LibraryHeaderBar.vala'),
    join_paths('Windows', 'EmulatorWindow.vala'),
    join_paths('Windows', 'LibraryWindow.vala'),
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
    css_gresource,
    c_args: c_args,
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.24.20'),
        dependency('gee-0.8', version: '>= 0.20.3'),
        dependency('glib-2.0', version: '>= 2.64.6'),
        dependency('granite', version: '>= 6.2.0'),
        dependency('libhandy-1', version: '>= 1.2.0'),
        dependency('retro-gtk-1', version: '>= 1.0.2'),
        dependency('sqlite3', version: '>= 3.31.1')
    ],
    vala_args: vala_args,
    install: true
)
