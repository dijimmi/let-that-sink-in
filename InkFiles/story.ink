EXTERNAL background(key)
EXTERNAL load_scene(scene)

-> start

=== start ===

Narrator: I was alone at home one day, watching my TV channel.

When suddenly, an emergency broadcast started playing.

News Reporter: Emergency Broadcast!

We have received numerous regarding a plague of talking sinks that knock on people's doors.

Sarah: What?

News Reporter: Just like that!
Talking sinks are invading people's homes.
They may appear friendly, but if you see a sink, DO NOT APPROACH THEM.
There have been cases of sinks reproducing inside people's homes and taking them over, leaving our citizens without a home.
If you encounter a sink, please do not interact.
Wait until they leave your door, and do not answer.

Sarah: That's so weird.
Imagine that, talking sinks.
I suppose people come up with every type of story...

Narrator: *knock knock*

Sarah: Shit...

-> opening_door

= opening_door

Sarah: Who are you?

Sink: I am a sink.
Would you let me in, please?

* Let that sink in. -> let_in
* DO NOT let that sink in. -> dont_let_in

= let_in

Narrator: Sarah lets the sink in...

GAME OVER

-> END

= dont_let_in

Sarah: Sure, give me a sec.

Narrator: Sarah rummages through her belongins.

~ background("gun")

Sarah: Try me again next time.

~ background("black")

Narrator: BANG!

-> intro2


=== intro2 ===

Narrator: ...

Sarah: I thought that was the end of them
Sarah: But soon enough...
Sarah: I found out I was wrong...

~ load_scene("level1")

-> END


=== error ===

There was an error choosing the path of the scene.

Please check StoryManager.

-> END

=== homeless_scene ===

~ background("black")

Narrator: Sarah, now homeless, walks through the woods in order to get help...

Sarah: Ugh, those stupid sinks!

Where did they even come from?

Did someone made sinks AI and they went rogue?

\*sigh*

Hopefully he can help me...

Honse: Who's there?
Show yourself or be prepared to suffer the might of-

Sarah: It's me! It's me!

Honse: Who are you? A Bipedal honse?

Sarah: You don't remember me?

Honse: I most certainly do not.

Sarah: Ah right... you didn't make it into the game...

My name is Sarah, I need your help.

Honse: My help?

Sarah: Yes!
Talking sinks have overtaken my home, and I have knowhere to go...
I knew I would find you here.

Honse: Why would I help you, bipedal honse? For I am the slayer of honses. I will defeat every honse that's in my way.

Sarah: Please, I beg you!
You are the mightest honse out there.
If there's anyone who can defeat them, it's you...
\*cries*

Honse: Crying won't convince me to spare you!

Sarah: I'm sorry, I...
I just remembered, my cat...
What will they do to him?
My poor cat...

Honse: Cat?

Sarah: A cute and flexible honse?

Honse: Oh no..
The cute and flexible one, we must do something to save him.

Sarah: Really?

Honse: Yes... I will help you.
Only for the cute and flexible honse.

Sarah: Okay...

Narrator: END OF CURRENT CONTENT

THANKS FOR PLAYTESTING!! <3333

~ load_scene("level2")

-> END

=== retry ===

Sarah: I must keep trying!

~ load_scene("level3")

-> END

=== finale ===

Sarah: Yay, I won!

-> END