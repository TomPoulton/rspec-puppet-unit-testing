class foo::bar {

    $my_var = does_something('blah')
    $hiera_var = hiera('key')

    if ($my_var == 'condition') {

        # do stuff, maybe another 'if' or two!

    }

    foo::baz { 'bazzy bazzy baz baz':
        param1 => 'one',
        param2 => 'two',
        require => Foo::Dependency['need me'],
    }
}
