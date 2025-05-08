# perlinema
a shoddy asciinema.org .cast file replayer, genuine 0 deps (you have perl installed I know it)

## features
- 0 deps just perl
- colors
- simulated typing on input
- mostly filtering out serial control codes (95% I'm not dealing with smeared out control codes)

## usage
```
perlinema xxxxxx.cast
curl https://asciinema.org/a/xxxxxx.cast | perlinema
```

## '''install'''
mv perlinema.pl /bin/perlinema
