;;;;The Overall Model;;;;

extensions[csv nw]

turtles-own[
  religion ;; colour will be changed according to the score & practice
  education_stand ; standardised education to fit jakobs equation
  education   ;; The original education level
  religious-practice ; score from 0-1 of one variable
  economy ;level of wealth, lognormally distributed within netlogo in set-up turtles
  partnered? ; used for interactions
  partner ; used for interactions
  attend ; binomial variable with yes or no
  attend?  ;
  potential-partner ; used for interactions
  edu-compatability ; used for interactions
  eco-compatability ; used for interactions
  rel-compatability ; used for interactions
  compatability ; used for interactions
  partner-match?
  ;;NB this wealth has to increase by the gdp growth rate per year - whether we make that a constant or across 52 ticks
  ;partner?
]


globals [
  average-religiosity
  average-education ; apparently we already have this in interface
  hdi
  gdp_per_capita
;;average-education  ;;keeps track of the average education level of the environment
  ;%atheist ;; later in the code, we are gonna specify that avg-rel is a mean of all scores
  ;slider-check-1
  ;slider-check-2
  ;slider-check-3
  ;eco
  boost-education ; button which boosts education of every agent by 0.5 when pressed, capped at 2.5
  average-economy]

;;;;;;;;;;;;;
;;;SETUPS;;;;
;;;;;;;;;;;;;

to setup
 clear-all ; clear all
 setup-patches ; blank background
 setup-turtles
 setup-globals
  reset-ticks
end

to setup-patches
  ask patches [set pcolor 131.5]
end


to setup-turtles  ;; here we assign the values to the turtles and define their shapes
   read-turtles-from-csv ;;function to read csv
   ask turtles[
   setxy random-xcor random-ycor
   set shape "person"
   set size 1.5 ;;additional paremeters of the turtles
    set potential-partner nobody
    set partner nobody
    set partnered? false
    assign-economy
    assign-color
  assign-attendance
  set education_stand education_stand + education-booster]
  ask turtles with [education_stand > 2.5] [set education_stand 2.5]
  ask turtles [set education education + education-booster]
  ask turtles with [education > 6][set education 6]
  ask turtles [set economy economy + economy-booster]
  ask turtles with [economy > 1] [set economy 1]
  ask turtles with [education_stand < -2.5] [set education_stand -2.5]
  ask turtles with [education < 1] [set education 1]

end

; function to read some of the turtle properties from a file
to read-turtles-from-csv
  file-close-all ; close all open files

  if not file-exists? "Sweden2018.csv" [
    user-message "No file 'turtles.csv' exists! Try pressing WRITE-TURTLES-TO-CSV."
    stop
  ]

  file-open "Sweden2018.csv" ; open the file with the turtle data

  ; We'll read all the data in a single loop
  while [ not file-at-end? ] [
    ; here the CSV extension grabs a single line and puts the read data in a list
    let data csv:from-row file-read-line
    ; now we can use that list to create a turtle with the saved properties
    create-turtles 1 [
      set religion    item 2 data
      set education_stand    item 3 data
      ;;set education   item 3 data
      set religious-practice item 5 data
      ;;set attend? item 7 data
      ;;ifelse attend? > 0 [set attend? true]
      ;;[set attend? false]

    ]
  ]

  file-close ; make sure to close the file
end


to assign-color
  ask turtles with [religion >= 0 and religion <= 0.25] [set color green ] ;; low religion = green
    ask turtles with [religion > 0.25 and religion <= 0.6] [set color blue ]  ;; medium religion = blue
  ask turtles with [religion > 0.6]  [set color red ] ;; high religion = red
end

to assign-economy   ;; random normaldistribution (0-1)
  ask n-of 399 turtles [set economy random-normal 0.5 0.1 ] ;; ask turtles to adopt a relevant score of economy
end

to assign-attendance
  ask turtles with [religious-practice > 0.5]
  [set attend? true set label "T"]
    ask turtles with [religious-practice <= 0.5]
  [set attend? false]

end


to setup-globals
  set average-religiosity mean [religion] of turtles ;; global variable (avg-rel is set to be a mean of all scores)
  set average-education mean [education] of turtles
  set hdi 0.893 ; HDI for Spain 2018
  set gdp_per_capita 30371 ; the gdp per capita for Spain 2018 (source: WorldBank, rounded to closest $ in USD)
  set average-economy mean [economy] of turtles

end




to-report random-near [center]  ;; define the random choince (don't understand completely- WHAT'S THIS FOR? )
  let result 0
  repeat 40
  [set result (result + random-float center)]
  report result / 20
end




;;;;;ALL Needs reworked ;;;;;

to go

 ; let x 0
 ; while [x >= 520] [
  ;;if ticks >= 520 [ stop ] ;; stop the simulation after 10 yrs
  if average-religiosity < 0.05 [stop]
  ;if count turtles with [color = red] =0 [stop] ;check this once we've figured out shapes/colours

  clear-last-round  ;action 1
  update-environment  ; action 2
  ; clear-links ; make all previous links die
  ;check-sliders  ; action 3

  ;now we're going to get those religious conversations flowing
  ask turtles [search-for-partner]
	let partnered-turtles turtles with [partnered?]
	ask partnered-turtles [update-score] ; ensure this updates both turtles scores
;  ask turtles [check-form] ; we want the turtles to check if they are the right colour/shape
  set gdp_per_capita gdp_per_capita * 1.0058 ; update the increasing economy or hdi scores
  ;will need to add in here anything else related to economy etc
  ask turtles[assign-attendance]
  ask turtles with [religious-practice < 0.5] [set label  ""]
    ask turtles[ assign-color]
	tick
;  set x x + 1
;  ]
end

;action 1
to clear-last-round   ;need to unpartner everyone
  ask turtles [set partnered? false
               set partner nobody
               set compatability 0
    set edu-compatability 0
    set eco-compatability 0
    set rel-compatability 0
    set partner-match? false
    set potential-partner nobody

  ]
  ;ask patches [];need to reset from decided color - see partner-up function, if partner-match true]
end


;action 2
to update-environment ; ensure your monitors are tracking etc - need to add more in probably
  set average-religiosity mean [religion] of turtles

end

;action 3
to check-sliders
  ;instructions
end

;; Partnerships <3 ;;







to search-for-partner
  let singles turtles with [potential-partner = nobody]

ask singles [
  lt random 40
  rt random 40
    fd 1]

 ask singles
  [
    if (potential-partner = nobody) and (any? other turtles-here with [potential-partner = nobody])
    [
      set potential-partner one-of other turtles-here with [potential-partner = nobody]

      ask potential-partner
      [
        set potential-partner myself

              ]
    ]

    if potential-partner != nobody  ; if turtles found a potential-partner, calculate how similar you are (on scale from 0-1)
    [calculate-compatability]
    if potential-partner != nobody
    [partner-up] ; this function also tells turtles to repeat this procedure if they do not match partner

  ]



end






to calculate-compatability ; this function creates a compatability score between 2 turtles which will determine whether or not they partner up.

  ;Education - setting compatability based on similarity of educational background
  ;remember to use the unscaled education for this calculation to avoid problems with plus and minus
    ifelse [education] of potential-partner = [education] of myself ;
     [set edu-compatability 1] ; do we need to ask the link to do this?
       [ifelse [education] of potential-partner = ([education] of myself + 1) or [education] of potential-partner = ([education] of myself - 1)
       [set edu-compatability 0.8]
            [ifelse [education] of potential-partner = ([education] of myself + 2) or [education] of potential-partner = ([education] of myself - 2)
             [set edu-compatability  0.6]
                 [ifelse [education] of potential-partner = ([education] of myself + 3) or [education] of potential-partner = ([education] of myself - 3)
                  [set edu-compatability  0.4]
                    [set edu-compatability  0.2]
  ]]]


  ;Now religious practice
  ;Here we want people who both practice religion to have more compatability, as they are more likely to mingle in the same circle.
  ;Yet, we don't want to create a bias such that just because you don't attend church you won't meet,so we'll leave the latter at a chance or mid-line value

  if attend?[
  ifelse [attend?] of potential-partner = [attend?] of myself ;
  [set rel-compatability 1]
  [set rel-compatability 0.5]

  ifelse [attend?] of potential-partner = [attend?] of myself ;
  [ask potential-partner [set rel-compatability 1]]
  [ask potential-partner [set rel-compatability 0.5]]
  ]





 ;Finally economy - this is on a gradient as our economic scores are also on a graditent
 ;Just like with education, we're assuming that those of a similar economic stance are more likely to interact.
 ;We don't want to bias so much, so beyond 0.4 away from your own economy we're setting a standard level of 0.4
    set eco-compatability  (1 - sqrt(([economy] of myself - [economy] of potential-partner) ^ 2) )


;Now the calculation - the overall compatability will be an average of the 3 factors, to be on a scale between 0 to 1.
  set compatability  ((edu-compatability + rel-compatability + eco-compatability) / 3)
end


to partner-up
  ;roll is going to let us control the probabilites of interacting more with those who are similar to you
  let roll random 99 ;

    ;depending on the compatability between these 2 turtles, probability is going to decide whether they partner
    ;the probability is weighted such that very compatible people have an 80% chance of interacting while incompatible people have a chance level of interaction

    if compatability >= 0.8 [set roll roll * 2.5  ] ; this means only numbers below 20 will not match => 80% chance of matching
  if compatability < 0.8 and compatability >= 0.6 [set roll roll * 1.67] ; this means only numbers below 30 will not match => 70% chance of matching
    if compatability < 0.6 and compatability >= 0.4 [set roll roll * 1.25] ; this means only numbers below 40 will not match => 60% chance of matching, slightly better than chance
    if compatability < 0.4 [set roll roll]
    if roll > 99 [set roll 99] ; this ensures roll will not go over 100 to stay within our scale of 0-100

   ;Roll is now going to be a number between 0 and 100 with the max number being 100. If the compatability score is above 50, they'll partner match.
   ;Basically says, there's a 50% chance of matching, but the more compatible you are, the more likely you are to have high score => more likely to match
   ifelse roll >= 49
    [set partner-match? true]
    [set partner-match? false]

   ifelse roll >= 49
    [set partner-match? true]
   [ask potential-partner [set partner-match? false]]




   ;assign partners and update the patches
    if partner-match?[
      set partner potential-partner
      set partnered? true

      ask partner [set partner myself]
      ask partner [set partnered? true]

      ;move turtles beside each other
      move-to patch-here
      ask partner [move-to patch-here]
  ]
    ;if they didn't match, release their potential partner and keep moving on for someone better to chat with
 ;   if not partner-match?[set potential-partner nobody]
  ;  ask turtles with [potential-partner = nobody] [keep-searching]
end


to keep-searching
  ask turtles  with [potential-partner = nobody] [search-for-partner]
end

to update-score ;
  let change  ( sin   ((-2 + ([education_stand] of partner)/ 10)  * pi *  ([religion] of partner) - ([education_stand] of partner)/ 20)  * ( 0.2 + (([education_stand] of partner)/ 20)  ))
  if change >= 0 [ set religion religion +  ((1 - ([ religion ] of self )) * change * 0.05 )  ]
  if change < 0 [ set religion religion  + (([ religion] of self)  * change  * 0.05) ]
  let change1  ( sin   ((-2 + ([education_stand] of partner)/ 10)  * pi *  ([religious-practice] of partner) - ([education_stand] of partner)/ 20)  * ( 0.2 + (([education_stand] of partner)/ 20)  ))
  if change1 >= 0 [ set religious-practice religious-practice +  ((1 - ([ religious-practice ] of self )) * change * 0.05 )  ]
  if change1 < 0 [ set religious-practice religious-practice  + (([religious-practice] of self)  * change * 0.05 )   ]

   set hdi hdi + 0.0000003846

end

@#$#@#$#@
GRAPHICS-WINDOW
289
56
726
494
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
week
30.0

BUTTON
62
102
125
135
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
170
102
236
135
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
769
260
1137
524
religiosity change
time
agents
0.0
520.0
0.0
50.0
true
true
"" ""
PENS
"religious " 1.0 0 -2064490 true "" "plot count turtles with [religion >= 0.6 ]"
"non-religious " 1.0 0 -11033397 true "" "plot count turtles with [religion <= 0.25 ]"
"attend" 1.0 0 -1184463 true "" "plot count turtles with [attend? = true]"

MONITOR
87
380
198
425
mean religiosity
average-religiosity
5
1
11

MONITOR
82
156
211
201
NIL
average-education
1
1
11

PLOT
963
36
1155
230
religiosity hdi 
NIL
NIL
0.0
520.0
0.2
1.0
true
false
"" ""
PENS
"default" 1.0 0 -13791810 true "" "plot average-religiosity"
"pen-1" 1.0 0 -2064490 true "" "plot hdi "

SLIDER
62
214
229
247
education-booster
education-booster
-5
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
54
321
226
354
economy-booster
economy-booster
0
1
0.0
0.1
1
NIL
HORIZONTAL

MONITOR
79
264
204
309
NIL
average-economy
4
1
11

PLOT
747
28
947
178
mean religiosity 
time (weeks)
rel-level
0.0
520.0
0.05
0.2
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot mean [religion] of turtles "

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="when will religion dissapear?" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="520"/>
    <exitCondition>count turtles with [color = red &lt;= 0]</exitCondition>
    <metric>ticks</metric>
    <enumeratedValueSet variable="economy-booster">
      <value value="0"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="education-booster">
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="comparison" repetitions="9" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="520"/>
    <metric>mean [religion] of turtles with [education &gt;= 4 ]</metric>
    <metric>mean [religion] of turtles with [education &lt; 4 ]</metric>
    <enumeratedValueSet variable="economy-booster">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="education-booster">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
