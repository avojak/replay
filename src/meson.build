conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', meson.project_version())

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

whalewatcher_files = files(
    join_paths('Application.vala'),
    join_paths('MainWindow.vala'),
    join_paths('MainLayout.vala'),
    join_paths('Widgets', 'HeaderBar.vala'),
    join_paths('Widgets', 'Dialogs', 'DebugDialog.vala'),
    join_paths('Utils', 'BitUtils.vala'),
    join_paths('DMG', 'Emulator.vala'),
    join_paths('DMG', 'Graphics', 'Display.vala'),
    join_paths('DMG', 'Graphics', 'GraphicsRegisters.vala'),
    join_paths('DMG', 'Graphics', 'LCDC.vala'),
    join_paths('DMG', 'Graphics', 'PPU.vala'),
    join_paths('DMG', 'IO', 'Joypad.vala'),
    join_paths('DMG', 'IO', 'SerialPort.vala'),
    join_paths('DMG', 'Audio', 'APU.vala'),
    join_paths('DMG', 'Audio', 'SoundRegisters.vala'),
    join_paths('DMG', 'Memory', 'AddressSpace.vala'),
    join_paths('DMG', 'Memory', 'BootRom.vala'),
    join_paths('DMG', 'Memory', 'MMU.vala'),
    join_paths('DMG', 'Memory', 'RAM.vala'),
    join_paths('DMG', 'Memory', 'ROM.vala'),
    join_paths('DMG', 'Memory', 'Timer.vala'),
    join_paths('DMG', 'Memory', 'Cartridge', 'Cartridge.vala'),
    join_paths('DMG', 'Processor', 'ALU.vala'),
    join_paths('DMG', 'Processor', 'CPU.vala'),
    join_paths('DMG', 'Processor', 'Jump.vala'),
    join_paths('DMG', 'Processor', 'Operation.vala'),
    join_paths('DMG', 'Processor', 'FlagRegister.vala'),
    join_paths('DMG', 'Processor', 'Registers.vala'),
    join_paths('DMG', 'Processor', 'InterruptManager.vala')
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    application_id,
    whalewatcher_files,
    config_header,
    # css_gresource,
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.6.4'),
        dependency('gee-0.8', version: '>= 0.8.5'),
        dependency('glib-2.0', version: '>= 2.30.0'),
        dependency('granite', version: '>= 0.6.0'),
        dependency('libhandy-1', version: '>=1.0.0')
    ],
    vala_args: vala_args,
    install: true
)
