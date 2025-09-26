# mptree
Tool for managing mp3 files in music directory. Use it with care.

Place "mptree" script somewhere, where $PATH environment variable points, and watch the magic:

1) mptree parse

   takes all the mess of musical files in the current directory, for example:

```
     All's Quiet On The Eastern Fron.mp3
     Secrets.mp3
     06 - Perfect Circle_(www.blahblahblah.dom).mp3
     07 - She's A Sensation.mp3
     Play For Today.mp3
     In_Your_House.mp3
     06 - polly.mp3
     Sitting Still.mp3
     some_gibber1sh.mp3
     another_shit_name.mp3
     07_-_Catapult.mp3
     10 - Come On Now.mp3
```

   extracts ID3 tags and sorts the mp3 files into the nice-looking directories, like this:

```   
     ./Nirvana/1991 - Nevermind:
        03 - Come As You Are.mp3
        05 - Lithium.mp3
        06 - Polly.mp3

     ./Ramones/1981 - Pleasant Dreams:
        02 - All's Quiet On The Eastern Front.mp3
        07 - She's A Sensation.mp3
        10 - Come On Now.mp3

     ./R.E.M./1983 - Murmur
        06 - Perfect Circle.mp3
        07 - Catapult.mp3
        08 - Sitting Still.mp3

     ./The Cure/1980 - Seventeen Seconds:
        02 - Play For Today.mp3
        03 - Secrets.mp3
        04 - In Your House.mp3
```

2) mptree "recursive_parse"

   the same as "parse" but applied to all mp3 files in all subdirectories (including the current directory) recursively

3) mptree mix

   converts parsed directories into the mixed list of the form "artist - title.mp3":
```   
        Nirvana - Come As You Are.mp3
        Nirvana - Lithium.mp3
        Nirvana - Polly.mp3    
        Ramones - All's Quiet On The Eastern Front.mp3
        Ramones - She's A Sensation.mp3
        Ramones - Come On Now.mp3
        R.E.M. - Perfect Circle.mp3
        R.E.M. - Catapult.mp3
        R.E.M. - Sitting Still.mp3
        The Cure - Play For Today.mp3
        The Cure - Secrets.mp3
        The Cure - In Your House.mp3
```

4) mptree list

   The same as "mix" but doesn't add artists in the file name, just creates a plain list of songs.

5) mptree clear

   deletes all empty directories (automatically runs after each task)
