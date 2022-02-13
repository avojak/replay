# Project name and programming language
# project('com.github.avojak.replay-tests', 'vala', 'c', version: '1.0.0')

# vala_args = ['--pkg', 'posix']

# application_id = meson.project_name()
# application_name = 'Replay Tests'

# meson.add_install_script('meson/post_install.py')

test_files = files(
    join_paths('TestCase.vala'),
    join_paths('TestHarness.vala'),
)
# test_files += application_files

# e = executable(
#     application_id + '-tests',
#     test_files,
#     dependencies: [
#         dependency('gee-0.8', version: '>= 0.8.5'),
#         dependency('glib-2.0', version: '>= 2.30.0')
#     ],
#     vala_args: vala_args,
#     install: false
# )

unit_test_files = [
    'Example'
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', test_files, dependencies: [
        dependency('gee-0.8', version: '>= 0.8.5'),
        dependency('glib-2.0', version: '>= 2.30.0')
    ]))
endforeach