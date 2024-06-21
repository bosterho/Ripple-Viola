rem @echo off

rem gm convert "ripple 1.png" -flop "ripple -1.png"
rem gm convert "ripple 2.png" -flop "ripple -2.png"
rem gm convert "ripple 3.png" -flop "ripple -3.png"
rem gm convert "ripple 4.png" -flop "ripple -4.png"
rem gm convert "ripple 5.png" -flop "ripple -5.png"

rem 0
rem 169
rem 26
rem 143
rem 52
rem 117
rem 78
rem 91
rem 104
rem 65
rem 130
rem 39
rem 156
rem 13
rem 182


for /l %%r in (-5,1,5) do (
	if %%r neq 0 (
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,0 "ripple %%r ch 1.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,169 "ripple %%r ch 2.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,26 "ripple %%r ch 3.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,143 "ripple %%r ch 4.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,52 "ripple %%r ch 5.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,117 "ripple %%r ch 6.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,78 "ripple %%r ch 7.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,91 "ripple %%r ch 8.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,104 "ripple %%r ch 9.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,65 "ripple %%r ch 10.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,130 "ripple %%r ch 11.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,39 "ripple %%r ch 12.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,156 "ripple %%r ch 13.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,13 "ripple %%r ch 14.png"
		rem gm convert "ripple %%r.png" -colorize 50,0,0 -modulate 100,100,182 "ripple %%r ch 15.png"

		for /l %%c in (1,1,16) do (
			copy "ripple.txt" "ripple %%r ch %%c.txt" 
		)
	)

	if %%r neq 0 (
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,0 "ripple swell %%r ch 1.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,169 "ripple swell %%r ch 2.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,26 "ripple swell %%r ch 3.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,143 "ripple swell %%r ch 4.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,52 "ripple swell %%r ch 5.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,117 "ripple swell %%r ch 6.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,78 "ripple swell %%r ch 7.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,91 "ripple swell %%r ch 8.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,104 "ripple swell %%r ch 9.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,65 "ripple swell %%r ch 10.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,130 "ripple swell %%r ch 11.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,39 "ripple swell %%r ch 12.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,156 "ripple swell %%r ch 13.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,13 "ripple swell %%r ch 14.png"
		rem gm convert "ripple swell %%r.png" -colorize 50,0,0 -modulate 100,100,182 "ripple swell %%r ch 15.png"

		for /l %%c in (1,1,16) do (
			copy "ripple swell 1.txt" "ripple swell %%r ch %%c.txt" 
		)
	)

)

rem pause
