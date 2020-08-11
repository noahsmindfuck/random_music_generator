#!/bin/bash
#playing 4 voices
#randomly choses between 2 scales and between two speeds


#defining standard parameters

#C Major Scale
#[0-8][9-17][18-28][29-38]
c_maj=(-30 -29 -27 -25 -23 -22 -20 -18 -17 -15 -14 -12 -10 -9 -7 -5 -4 -2 0 2 3 5 7 8 10 12 14 15 17 19 20 22 24 26 27 29 31)
c_min=(-31 -29 -27 -26 -24 -22 -20 -19 -17 -15 -14 -13 -11 -9 -7 -6 -4 -2 -1 1 3 5 6 8 10 11 13 15 17 18 20 22 23 25 27 29 30)

#Starting scale and scales to switch in between
scales=("c_maj" "c_min")
scale=${scales[0]}

#choices for breaks between notes, 0.8 means less breaks (0.8*hold_time)
#<breaking> holds the (starting) value
breaks=(0.8 1)
breaking=${breaks[0]}

#chose 1 to randomly leave out notes of voices
random=0

value=0.01
max=1
min=0
while ( true )
do
	#chance to switch scales
	if [ $(shuf -i 0-10 -n 1) -eq 0 ]
	then
		scale=${scales[0]}
		scales=(${scales[1]} ${scales[0]})
	fi

	#chose random note from scale
	sop_note=$(shuf -i 25-38 -n 1)
	alt_note=$(shuf -i 15-31 -n 1)
	ten_note=$(shuf -i 9-23 -n 1)
	bas_note=$(shuf -i 0-15 -n 1)

	if [ $scale == "c_maj" ]
	then
		soprano=" sine %${c_maj[$sop_note]}"
		alt=" sine %${c_maj[$alt_note]}"
		tenor=" sine %${c_maj[$ten_note]}"
		bass=" sine %${c_maj[$bas_note]}"
	fi
	if [ $scale == "c_min" ]
	then
		soprano=" sine %${c_min[$sop_note]}"
		alt=" sine %${c_min[$alt_note]}"
		tenor=" sine %${c_min[$ten_note]}"
		bass=" sine %${c_min[$bas_note]}"
	fi

	notes_to_play=""
	#decision based on wether GLOBAL <random> is set or not
	if [ $random == 1 ]
	then
		#randomly chose notes to play
		if [ $(shuf -i 0-10 -n 1) != 0 ]
		then
			notes_to_play=$notes_to_play$soprano
		fi	
		if [ $(shuf -i 0-10 -n 1) != 0 ]
		then
			notes_to_play=$notes_to_play$alt
		fi	
		if [ $(shuf -i 0-10 -n 1) != 0 ]
		then
			notes_to_play=$notes_to_play$tenor
		fi	
		if [ $(shuf -i 0-10 -n 1) != 0 ]
		then
			notes_to_play=$notes_to_play$bass
		fi	
	else
		#or play all
		notes_to_play=$soprano$alt$tenor$bass
	fi

	#Randomly generate duration of sound
	holt=$(echo " 1 / $(shuf -i 1-10 -n 1) * $(shuf -i 1-3 -n 1)" | bc -l)
	
	#randomly choose to make longer/shorter breaks between notes
	if [ $(shuf -i 0-10 -n 1) -eq 0 ]
	then
		breaking=${breaks[0]}
		breaks=(${breaks[1]} ${breaks[0]})
	fi

	#Shape the note for smooth sound
	fade_in=$(echo "0.1 * $holt" | bc -l)
	hold_time=$(echo "0.8 * $holt" | bc -l)
	fade_out=$(echo "0.1 * $holt" | bc -l)

	#execute the play command
	play -qn synth $holt $notes_to_play \
		fade h $fade_in $hold_time $fade_out \
		remix - 2>/dev/null & sleep $(echo "0.8 * $holt" | bc -l)

done
exit

