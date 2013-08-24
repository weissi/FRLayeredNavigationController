Coding Conventions
==================

 - 120 characters per line
 - 4 spaces instead of tabs
 - no trailing whitespace (or other whitespace errors)
 - define methods like in the code sample below
 - Use autosynthesization (instead of old `@synthesize`)

Sample code
-----------

    - (SomeType *)myMehodName
    {
        /* code */
    }


Check script
------------

Just run `./syncheck.sh` in the root directory of FRLayeredNavigationController.

Automatic check when committing
-------------------------------

Just paste the following in a terminal (being at the root directory of
FRLayeredNavigationController). Paste it entirely (one-shot). This will give you
automatic checking when committing.

    cat > .git/hooks/pre-commit <<EOF
    #!/bin/sh
    
    echo "Checking syntax"
    echo "---------------"
    ./syncheck.sh
    if [ $? -ne 0 ]; then
        echo "-------------------------------------------------"
        echo "SYNTAX CHECK FAILED, CANNOT COMMIT. Please fix..."
        echo
        echo "If you really can't fix the syntax errors use"
        echo "    git commit --no-verify ..."
        exit 1
    fi
    
    exit 0
    EOF
    chmod +x .git/hooks/pre-commit
    
