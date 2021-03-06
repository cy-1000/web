---
title: Logic Programming
headerImg: sea.jpg
---

# Logic Programming

(adapted from lecture notes by Henri Casanova and Todd Millstein)


## Introduction


We now turn to a brand new paradigm, called "Logic Programming Languages"
-- our vehicle for studying this paradigm is Prolog, whose roots are
in logic and on automated theorem proving.
Prolog was developed in the 1970s for AI applications. Some such applications
have a knowledge base (or database) of facts, from which you'd like to
ask queries and deduce other facts.  For example, given facts in the
knowledge base like "Carnitas is Mexican" and "Mexican food is delicious",
then we can deduce "Carnitas is delicious".

Prolog probably looks nothing like any language you've seen before.
Fundamental difference between Prolog and most other languages:

      You don't run a Prolog Program

Instead, you ask questions and the system attempts to answer them using the
rules and facts that it has been given.

      Logic programs are "declarative": the specification of the
      desired results are written, rather than how to obtain them.

This approach is very good at expressing problems that involve searching
a large space of possibilities.  For example, given a list of cities and
distances between them, find me the shortest route that passes through
each one once (the travelling salesman problem).

The philosophy of this approach is that it is often hard to specify a
search algorithm -- and in such cases, it is easier to specify
the characteristics of the solution.
To do so, you specify *facts* and *rules* for deducing new
facts from old facts, and then a *query*.  So you just state what is
true and then ask what (else) is true.  The language implementation figures
out how to actually compute appropriate solutions.
Use the travelling salesman problem as an illustration:  I say
the constraints, not how to search the space of possible solutions.
Of course, as we will see, this is a simplification, and often for reasons
of efficiency, one has to impose constraints on the search.

The original and principal applications for Prolog are in various AI
settings such as (expert databases). Examples include using prolog-based
databases to determine when credit card fraud has occurred (prolog is used
to specify rules that indicate when a fraud occurs), and there are
projects afoot to use ideas from prolog to determine suspicious
people from phone/communication patterns.
Note that currently AI researchers devise statistical techniques to
complement (if not replace) logical approaches for such tasks.
Another big application is as a database query language.  
E.g., my facts are things like the daily stock prices of various
stocks over the last year.  Queries can be things like: find me all
pairs of stocks that had the same price on the same day at least 50
times this year.  
Standard query languages like SQL are inspired by and are really subsets of Prolog.
Of course, the reason we're studying it is that its a radically different
way of thinking about computation: "programming as proving".
You'll be surprised at how many places this paradigm fits beautifully, or
leads to very elegant and readable systems.

## Terms


Based on propositional logic. The entire program comprises three kinds of
elements: facts, rules, and queries. The basic unit of each of these are
terms.

Terms are Prolog's way of encoding data. They are very similar to the
values of datatypes created in ML. There are three kinds of terms:
constants, variables and compound terms.

1. **Constants**: The simplest kind of terms are constants.

  - _integers_ and _reals_: are constants.

  - _atoms_: are identifiers starting with a lowercase letter.

    For example:

    `alice`, `bob`, `charlie`  

    are all atoms.

    **Atoms are NOT variables** -- the way to think of them is as TAGS,
    or special constants, or elements of a giant enum datatype.
    They are similar to the tags used in ML datatypes:

~~~~~{.ocaml}
    type day = Alice | Bob | Charlie ...
~~~~~

    Only in ML, the tags start with a capital letter.

    Atoms are *uninterpreted constants*:  nothing is known about each tag
    except that it is equal to itself.

    Intuitively, Prolog knows that:

    `alice = alice`

    as the tags are the same. However, to it,

    `alice = bob`

    *never* makes sense, as it has a strange notion of equality, that we
    will see shortly.

    There are some built-in atoms such as `[]` that signifies the empty
    list, `.` which is used for list concatenation and so on, that we will
    see shortly.

2. **Variables**: Any identifier beginning with an upper case letter
  or an underscore is a variable.

   For example,

   `X`, `Y`, `Head`, `Tail`, `Alfred`

   are all variables.

   The variable `_` is like a **wildcard" variable**, whose meaning
   is similar to the `_` in ML, but more on that when we see what a
   variable means.

   As we shall see:

     --  `x = a` is nonsense (as x and a are two *different* constants/tags).
     --  `X = a` has some sense (but isnt at all what one might think...).

   WARNING: Upercase/Lowercase is a common source of error! Also, variables
   are NOT declared before use (so be careful!).

3. **Compound Terms**: These are terms of the form: atom(term,term,term,...)
   where each "term" is either an atom or a variable or a compound term.
   Examples include:

~~~~~{.prolog}
      x(y,z)
      parent(alice,bob).   %here alice,bob are atoms
      parent(alice,Child). %here alice is an atom, Child is a variable
~~~~~

   In other words, (compound) terms are generated by the following grammar:

~~~~~{.prolog}
	atom := [a-z][A-z,a-z,0-9]* | [0-9]* | ...

	variable := [A-Z][a-z,A-Z,0-9]* | _

	term := atom | variable | atom(term,term,term,...)
~~~~~

   While you may be tempted to think of compound terms like:

   `parent(alice, bob)`

   as function calls, they are NOT! Instead, you should think about this
   in the same way as we thought of ML the recursive, one-of types in ML.

~~~~~{.ocaml}
   type term =   alice | bob | charlie | ... (* other atoms *)
             | Var of string
	           | Parent of term * term
~~~~~

   Thus, `parent(alice, bob)` in Prolog is "equivalent to" the ML value:

   `Parent(alice, bob)`

   which is just a tuple `alice, bob` with a tag `Parent` on it, or
   equivalently represented as a tree:

~~~~~
          Parent
			     /  \
			    /    \
			  alice  bob
~~~~~

   and parent(alice,Charlie) in Prolog is "equivalent to" the ML value:
   Parent(alice,Var ("Charlie")), or represented as a tree:

~~~~~
			    Parent
			     /  \
			    /    \
			  alice  Var
				  |
				  |
				Charlie
~~~~~


Consider a term: `factorial(5)`

It is **NOT a function** (despite what it looks like).

  - there is no associated function implementation

Prolog has no idea of the meaning you intend for this term -- to it,
this is just a box containing `5` with a label `factorial`.

Another way to view it is as a tree:

~~~~~
			factorial
			    |
			    |
			    5
~~~~~

Thus, the only thing Prolog knows is that:

`factorial(5)=factorial(5)`


i.e. the two terms are the same. In particular, to Prolog,
`factorial(5)=120` is NOT true.

Thus Prolog compound terms are really just structured data -- like values
of a datatype in ML. Can also think of atoms that begin a compound term
as *uninterpreted functions*: e.g., `factorial` is a function about which
NOTHING is known, except that the result of applying this function to the
atom x, is the term `factorial(x)`.

These atoms are called **function symbols**.

## Facts

A fact is just a term, typically without any variables.
You specify a fact by writing a term followed by a '.'.
For example, here are a few facts that one might have
in the system.

~~~~~{.prolog}
% List of parent relationships
parent(kim,holly).  
parent(margaret,kim).  
parent(herbert,margaret).
parent(john,kim).
parent(felix,john).  
parent(albert,felix).
~~~~~

Note that `kim`, `holly`, `margaret`, `herbert`, `john`, `kim`, `felix`, `albert`
are all atoms.

The Prolog interpreter maintains a collection of facts like the above --
think of it as the underlying data in the database over which queries will be asked.  
You can define your own facts and add them to the database.  The function
symbols beginning a fact are called *predicates*:  intuitively, they
represent functions that evaluate to a boolean.

Thus, (the atom) `parent` is a predicate that, intuitively,
takes two arguements and returns a boolean -- we say that
`parent` is a predicate of arity 2.

The key thing to note, is that predicates have _no intrinsic meaning_.
However, they are generally designed and named so that
the programmer can easily "interpret" them.

For example, as a programmer, I will decide that

~~~~~{.prolog}
parent(X,Y)
~~~~~

means that `X` is a parent of `Y`. In other words,
I will specify the fact:

~~~~~{.prolog}
parent(a,b).
~~~~~

only if the person corresponding to atom `a` is
a parent of the person corresponding to atom `b`.
Thus, the predicate is interpreted as a logical
relation between `X` and `Y`.

Prolog uses these facts to answer queries, as well
as to infer new facts.

Lets see how it does the first.

## Running Prolog : Queries  

HEREHEREHEREHERE

The standard interface to Prolog is in an interactive shell.
To run it, first, lets put a bunch of facts into a file, and then load the
file into the shell. Suppose the list of facts are stored in a file called
"facts.pl". First, we load prolog, and get the shell prompt:

Prolog prompt:   "?-"

At this prompt, enter something like:

?- consult('facts.prolog').     

You can manually add the facts one by one by typing at the prompt:

?- assert(parent(margaret,kim)).

(or whatever fact you want to insert).

Once this is done, the facts have been registered into the shell, we can query Prolog as follows:

    1. Prompts you to type a query
    2. You type a query
    3. Prolog tries to prove your query
    4. Prints out the result (or 'failure')
    5. Repeat

The simplest query is a term followed by a '.'
(looks like a fact, but is just typed at the prompt).
For example, suppose you type the following query:

?- parent(margaret, john).  

The meaning of a query is "is this fact in your database or can it be
inferred from your database". In other words, we are asking Prolog if it
can PROVE the fact. Prolog replies:

No

as this is not one of the facts (we have not yet given it any rules to
infer new facts).
Instead, if we were to ask:

?- parent(margaret,kim).

Prolog replies:

Yes

As this is in the database of facts we fed in.
(Tip: If you forget the period then you can type it on the next line)
Not bad, but not especially exciting -- we gave it a bunch of facts, and
basically each query is effectively asking if the query term was one of the
facts we supplied.

Things get more fun, when we toss variables into the queries.

      ?- parent(margaret,X).

This is where we Prolog departs radically from other paradigms. The meaning
of this query is:

"What value(s) can you plug in for X such that the fact becomes provable for that value ?"
Prolog replies:

      X = kim 	[press enter if you're satisfied]
	Yes

This means that it can plug in "kim" for X, and thus, it can deduce the
fact: parent(margaret,kim). Instead, you can enter the query:

      ?- parent(X,kim).

This asks prolog, for what values of X does the fact parent( _ , kim) hold.
In other words, this innocent query is asking prolog -- who are the (known)
parents of kim ? It replies:

	X = margaret   ;	[press ';' if you want another answer]
        X = john  ;
	No

Thus, it returns, one-by-one, all the "solutions" for X that make the fact
parent(X,kim) provable. We can make both the parameters variables:

      ?- parent(X,Y).  

This asks prolog -- what are the pairs X,Y such that X is (provably) the
parent of Y ? It responds:

	X=kim  Y=holly ;
	X=margaret  Y=kim;
	...

Suppose you want to know if there are any strange circularities in your
fact database -- for example, does there exist any person who is their own
parent ? The following query does the trick:

      ?- parent(X,X).  
      	No

------------------------------- Unification -----------------------------------

In most other languages, a function designed to look up
things like this would be less flexible -- it would require tedious
parentOf() method or a childOf() method, loops, etc.
With Prolog -- the queries are very flexible, and work like magic.
Whats going on ?

Turns out that Prolog's computational heart is a fancy pattern matching
technique (also, btw, at the heart of ML's type system) borrowed from
logicians,  called "Unification". Regrettably, we won't have time to go
into the details of unification -- and so, lets content ourselves with a
cartoon version.


	Intuitively, two terms can be unified   if there a
	way of assigning values to their variables so that
	the terms become identical.

This is really what " = " means in prolog -- when you ask it:

	?-  t1 = t2.

For any two terms t1 and t2, you are asking it whether the terms t1 and t2
can be unified. So, if you ask:

   ?- foo(bar) = foo(bar).
      Yes

Because there are no variables and the terms are the same.
If instead you ask:

   ?- foo(X) = foo(bar).

It replies:
      X = bar
      Yes

Meaning that foo(X) can be unified with foo(bar) by assigning the variable
X to the term "bar".
Note that we can ask this from Prolog without "declaring" any of the above
atoms. This is because everything is symbolic -- everything is a term which
is an arbitrary  notation that can encode whatever concept.
One can type the above right after starting the interpreter.


The more interesting case is when there are several variable in the terms:

   ?- p(X,dog) = p(cat,Y).
      X = cat
      Y = dog
      Yes

meaning that one can unify the terms p(X,dog) and p(cat,Y) by assigning
appropriate values to X and Y. However, if we were to ask:

   ?- p(cat) = p(dog).
      No

As the terms are different, and so, if we ask:
   ?- q(X,dog,X) = p(cat,Y,Y).
      No

is the answer as to unify, X must be "cat" and Y must be "dog", but this
ensures that the last parameter of the term can never be the same!

Similarly, the unification happens "deep" into the terms:

?- a(W,foo(W,Y),Y) = a(2,foo(X,3),Z).
      W = 2
      X = 2
      Y = 3
      Z = 3
      Yes

Intuitively, it first matches up the first position, and so W gets 2,
next, it tries to match up the second position -- i.e.

	foo(W,Y) with foo(X,3).

now, W is already 2, so X also gets 2, and Y gets 3.
Finally, it tries to match up the last position,
and Y is 3 and so Z gets 3.

Instead, the query:

?- a(W,foo(W,Y),Y) = a(2,foo(X,3),X).
   No

Thus, by using W,X,Y in two places, we are forcing it to find a solution where
those two places get exactly the same value. As a result, the constraints
ensure that all the variables must get the same value. However, W and Y
must get 2 and 3 and so there is no solution.

Thus, this innocent "pattern matching" operation actually does a lot under
its hood, and it turns out to be a surprisingly powerful and flexible way
to encode all kinds of computation! All the queries that we asked before,
were answered via unification.

When we ask:

	?- parent(margaret, john).  

prolog checks if the term "parent(margaret,john)" can be unified with any
of the known facts (that are also terms). If so, it says Yes, but as it
cannot, it replies No.

When we ask:

	?- parent(margaret,kim).

it can unify the query term with a known fact term, and so it replies Yes.

When we ask:

	?- parent(margaret,X).

it tries to find all the known facts with which it can unify the query term
-- there is only one, and so it "answers the query" by returning the
substitution required for unification:
	X = kim

Similarly, when we ask:

      ?- parent(X,kim).

It attempts to find all the known terms with which this query can be
unified -- this time, there are several terms, and the different
valid unifying substitutions (called unifiers) yield the different parents
of kim:
	X = margaret   ;
        X = john  ;
	No

Finally, to answer the query:

	?- parent(X,Y).

It attempts to unify the query term with all known facts -- and the list of
resulting unifiers is exactly the set of known parent child pairs.

------------------------------- Conjunction ------------------------------

Often, its more useful to ask questions about several terms.
For example, to determine if margaret is holly's grandparent, we would like
to find if there is some person who is both the child of margaret AND the
parent of holly.
To do so, we can issue a conjunctive query which is a list of terms
separated by commas as follows:

      ?- parent(margaret, X), parent(X, holly).

To answer this query, Prolog attempts to find an X such that
parent(margaret,X) unifies with the set of known facts, AND,
parent(X,holly) unifies with the set of known facts.
Upon finding a unifier that works, it replies:

	X = kim
	Yes

Thus, as kim is the intermediate parent, we can conclude that margaret is
indeed a grandparent of holly. Finally, consider the following query:

      ?- parent(X,Y), parent(Y,Z), parent(Z,kim).

It asks if there are X,Y,Z such that X is Y's parent, Y is Z's parent and Z
is kim's parent. In other words, the query determines if kim has any
"great-grandparent". Upon finding appropriate unifiers, prolog replies:

	X = john
	Y = felix
	Z = albert
	Yes

------------------------------- Rules ------------------------------------

The above is quite nifty -- it allows us to quickly mine the database to
find interesting relationships. However, it gets somewhat cumbersome as we
have to devise a complex conjunctive query ever time.
Instead, it would be nice if we could define complex queries out of simpler
queries.

Rules serve exactly that purpose. They allow us to specify complex queries
(i.e. predicates) using simpler ones. In general, the format of a rule is:

     head :- condition1, condition2, condition3....

Intuitively, it means, that the "head" query is true if condition1,
condition2, condition3,... are all true. In other words, it tells prolog,
to prove the head query, prove the conditions 1,2,3.

For example, suppose we'd like to define a grandparent relationship
(predicate). We do so as:

    grandparent(GP,GC) :- parent(GP,P), parent (P,GC).

Intuitively this states:

   "GP is a grandparent of GC if GP is a parent of P AND P is a parent of GC".

With this definition, we can now issue the following query:

      ?- grandparent(X,kim).

and prolog responds with:

	X=herbert
	Yes

as it can find that parent(herbert,margaret) and parent(margaret,kim),
therefore, applying the rule, grandparent(herbert,kim), to which fact the
query term gets unified. We can use this predicate to write more
predicates:

    greatgrandparent(GGP,GGC) :- parent(GGP,GP) , grandparent (GP, GGC).

We can now issue the query:

    ?- greatgrandparent(X,holly).
       X=herbert
       Yes

Program = Facts + Rules:
------------------------

Facts and Rules are the two kinds of "Clauses" (intuitively, a fact is
just a rule without any conditions).
Thus, a prolog program is a set of clauses -- partitioned into a
database of facts and a set of rules for inferring new facts.

Scope:
------
Notice that the same variable P appears twice in the grandparent rule.
Indeed one may be tempted to reuse P across several rules. In Prolog, the
scope of a variable is the clause (rule) that contains it. Thus, there is
no connection whatsoever between variables across clauses.

For example, consider the two clauses:

       foo(P) :- bar(P).        % There is no connection between P in
       stuff(P) :- thing(P).    % the 2 clauses.

In other words, there are no global variables, all variables are local to
the individual clauses.

------------ Multiple Clauses =  Disjunction and Recursion ---------------

Suppose we want to define a predicate that is true for all those persons
that have some family -- that is, those persons who have either a parent OR
a child. We can do so as follows:

	has_family(X) :- parent(X,_).
	has_family(X) :- parent(_,X).

If we have multiple rules for the same predicate, effectively we are
specifying a disjunction. The first rule says:

   "X has a family if there is some _ such that X is the parent of _"

The second rule says:

   "X has a family if there is some _ such that _ is the parent of X"

If either of these clauses fire then, has_family(X) becomes true.
Like in ML, the symbol "_" represents a "wildcard" or dont-care
variable that we will use only in one place and so we not bother
to name it.

Thus,
   ?- has_family(holly).
   Yes

as the second rule fires for holly. While,

   ?- has_family(mugatu).
   No

as neither rule fires for mugatu.

For those of you who are economical with the keystrokes, there is another
way to specify disjunctive rules -- via a semicolon:

   has_family(X) :- parent(X,_) ; parent(_,X).


Suppose you want to specify an predicate ancestor(X,Y) which is true if
X is an ancestor of Y, i.e. if by following the parent relationship from Y
one eventually reaches X. Intuitively, X is an ancestor of Y either if:

	1. X is the parent of Y, or,
	2. Z is the parent of Y, and X is an ancestor of Z.

Thus, we can specify this predicate recursively as follows:

    ancestor(X,Y) :- parent(X,Y).                %[Base case]
    ancestor(X,Y) :- parent(Z,Y),ancestor(X,Z)   %[Recursive case]

This works quite niftily:

    ?- ancestor(kim,X).
       X = holly ;
       No

i.e. holly is the only "descendant" of kim, and:

    ?- ancestor(X,kim).
       X = margaret ;
       X = john ;
       X = herbert ;
       X = felix ;
       X = albert ;
       No

i.e. kim has a long ancestry.

----------------------------- Backtracking Search ---------------------------

At this point, its worth looking into how exactly prolog pulls off this
trick of answering queries in this manner, as it has its limits, which one
needs to know to phrase the queries appropriately. Turns out, there's no
real magic -- just brute force "proof" search.

We can view each clause as a "proof rule":

      goal :- subgoal_1, subgoal_2,...

Thus, the rules for ancestor are as follows:

ancestor(X,Y) :- parent(X,Y).			%rule 1
ancestor(X,Y) :- parent(Z,Y),ancestor(X,Z).	%rule 2

To prolog, these rules mean the following -- to prove ancestor(X,Y), try to:

  1. prove the subgoal parent(X,Y), or, failing that,
  2. prove the subgoal parent(X,Z), and then the subgoal ancestor(X,Z).

Thus, suppose we ask it the query:

  ?- ancestor(felix,holly).

To prove this query, it undertakes the following backtracking search:


		ancestor(felix,holly)?
		  /		\
     parent(felix,holly)    parent(Z,holly)
	  NO		    ancestor(felix,Z)
				|
				| Z = kim  (by fact)
				|
			  ancestor(felix,kim)
			  /        \
	  parent(felix,kim)     parent(Z',kim)
	      NO                ancestor(felix,Z')  ----------|
			         |                            | Z'=john
		     Z'=margaret |                            |
				 |                        ancestor(felix,john)
		     ancestor(felix,margaret)                 |
		        /        \                         parent(felix,john)
	parent(felix,margaret)   parent(Z'',margaret)         YES
		    NO           ancestor(felix,Z'')
                                     |
		    Z'' = herbert    |
		                     |
			   ancestor(felix,herbet)
			     /              |
		 parent(felix,herbert)   parent(Z''',herbert)
		      NO			NO

Thus, it first tries the base rule i.e. to prove the subgoal parent(felix,holly).
As it cannot unify this query with any known fact, it fails (NO),
and so it backtracks and tries the other recursive rule.
The only Z such that parent(Z,holly) unifies with a known fact is when
Z=kim, thus, it tries to prove the second subgoal ancestor(felix,kim).
To do so, again it first applies the base rule, which fails, and so it
backtracks and applies the recursive rule.

This time, there are two different Z (written Z' in the figure to
distinguish from the upper part of the tree), such that parent(Z,kim) --
namely Z=margaret and Z=john. It picks margaret first (as that is the first
unification that succeeds, and tries to prove the the second subgoal
ancestor(felix,margaret). As we can see, from the subtree, this search
fails, (as margaret's sole parent is herbert who has no parent).

Thus, prolog backtracks and tries the second Z=john, and tries to prove the
second subgoal, ancestor(felix,john). This time, the base rule works as
parent(felix,john) is a known fact, and thus the proof search succeeds and
prolog returns:

  ?- ancestor(felix,holly).
     Yes

This same process is repeated for any query. When there is a variable in
the query, eg.

  ?- ancestor(X,kim).

Prolog attempts the proof search and returns all the unifiers for X for which
the proof succeeds. Thus, prolog is literally programming by proving.


Hint: Trace mode in prolog shows the tree:

    ?- trace.

The subsequent query is traced: use the on-line help on the ACS Prolog interpreter

    ?- help(trace).

Order Matters:
--------------

The rub is that the order of the clauses and terms influences greatly the order
in which the unification and backtracking happens. This is because, to
prove a particular goal query, the different clauses are selected in
order, and further, within each clause, the subgoals are selected from
left-to-right, which affects how the unification happens.

In the above example, if we had entered the branch Z'=john rather than
than the branch Z'=margaret, then we would have proven the query faster.
Similarly, if we had swapped the order of the conjunctions (subgoals) in
the recursive clause, we would have a rather different tree (try as an
exercise). Thus, order matters for performance.
Hint: Try simple things first!  

More importantly, there are cases where the program may not even work (may
not terminate), depending on the order:

    ancestor(X,Y) :- ancestor(X,Z), parent(Z,Y).
    ancestor(X,Y) :- parent(X,Y).

Now lets try the same query:

    ?- ancestor(felix,holly).
     ERROR: Out of local stack

Why ? Well, if you try to build the search tree, you'll see it goes forever:

		ancestor(felix,holly)?
		        |
			|
			|
		ancestor(felix,Z)  %prove first subgoal,
			|          %then parent(Z,holly)
			|
			|
		ancestor(felix,Z') %prove first subgoal,
			|	   %then parent(Z',Z)
			|
			|
		ancestor(felix,Z'')
			.
			.
			.

So, to avoid this, we must place the parent subgoal first (in the recursive
rule). If this is done, the unification with the base facts (parent),
fix the possible unifiers for Z, thereby guaranteeing termination.

Lets see another example. Suppose we want to define a sibling predicate,
where sibling(X,Y) holds if X and Y have the same parent. How about:

    sibling(X,Y) :- parent(P,X), parent(P,Y).

Almost:

    ? sibling(kim,kim).
    Yes

Ah, we have to ensure that X and Y are not the same. Ok, how about:

    sibling(X,Y) :- not(X=Y), parent(P,X), parent(P,Y).

Surely this works ? Nope. The reason is prolog's semantics of equality
(i.e. unification). This clause is read by prolog as:

first, find a X,Y such that X cannot be unified with Y,
then, find a P such that parent(P,X), and parent(P,Y).

Now the catch is that to process the first subgoal, prolog finds it can
always unify (two unconstrained variables) X and Y, by simply assigning X to Y!
	?- X=Y.
	X=Y
	Yes

	?- not(X=Y).
	No

Thus, the very first subgoal always fails, thereby ensuring that:

	?- sibling(X,Y).
	No

Thus, to get the rule right, we must make sure that the goal that ensures
that X and Y are not the same, is fired AFTER X and Y have been unified
with appropriate atoms. We can do so by simply placing the subgoal at the
end.
    sibling(X,Y) :- parent(P,X), parent(P,Y), not(X=Y).

    ?- sibling(X,Y).
    X = john
    Y = maya ;

    X = felix
    Y = dana ;

    X = dana
    Y = felix ;

    X = maya
    Y = john ;
    No

This shows a major weakness: You can's just rely on the logical
meanings and you sort of need to know how things work.
Oh well, nothing's perfect.
We'll see that many, many things break down the pure philosophy
that says: "Just write what you need logically"

---------------------------- Numeric Computation --------------------------

Although Prolog is mostly symbolic, there is a need for numeric
computation.

  - '=' is the unification operator
	?- X = 2+3.
	    X = 2+3
	    Yes
  - 'is' evaluates arithmetic expressions before doing unification
	?- X is 2+3.
	    X = 5
	    Yes
When prolog tries to solve an "is" goal it evalutes the second argument
and then unifies, as opposed to "=" which just does the unification.

	?- Y is X+2, X=1.
 	ERROR: Args are not sufficiently instantiated

	?- X=1, Y is X+2.
          X=1
          Y=3
          Yes

Again, order of evaluation matters!

Functions are Predicates:
-------------------------

Lets try to write a factorial function in Prolog. We need to somehow encode
functions as predicates. Here's the deal:
Whenever you have a function f(x), you can write a predicate

	pred_f(X,Y)

that captures the behavior of f by being true for all those pairs X,Y
where Y is f(X).

Thus, we can write a predicate capturing the input/output relationship of
the factorial function -- i.e. a predicate factorial(X,Y), that is true for
those pairs X,Y where Y is the factorial of X.

	factorial(0,1). % base case
	factorial(X,N):- X1 is X-1, factorial(X1,N1), N is X1*N1.

We "call" the function with a query.

	?- factorial(0,X).
	X = 1
	Yes

	?- factorial(5,X).
	X = 120


---------------------------- Data Structures: Lists --------------------------------

Let us now see how we can encode lists in Prolog. Again, its useful to
recall how lists were encoded as a datatype in ML.
 -- There is a "base atom": [] denoting the empty list
 -- There is a "cons"tructor: | (different syntax for this).

Thus, ML's list Cons(1,Cons(2,Cons(3,Nil))) is equivalent
to the prolog term:

	[1|[2|[3|[]]]]

where (1) | is Cons, and (2) [] is Nil.

Also, as they are heavily used, Prolog lets you write the above term as:
[1,2,3].

	?- [1,2,3] = [1|[2|[3|[]]]].
	Yes

To "deconstruct" a list into head and tail, we use pattern-matching (very
much like in ML). So:

  [X|Y] unifies with any non-empty list (like h::t),
  	X unified to the first element (head)
	Y unified to the rest of the list (tail).

	?- [X|Y] = [1,2,3,4,5].
	X = 1
	Y = [2,3,4,5]
	Yes

	?- [X|Y] = [1].
	X = 1
	Yes

	?- [X|Y] = [].
	No

  [1|Y] unifies with any list starting with 1 (like 1::t),
  	Y unified to the rest of the list.


  However, prolog also lets you write:

  [1,2|X] which unifies with any list that starts with 1 and then 2.
  	?- [1,2|X] = [1,2,3,4,5].
	   X = [3,4,5]
	   Yes

	?- [1,2|X] = [1,2]
	   X = []
	   Yes

	?- [1,2|X] = [1,3]
	   No

	One can place variables wherever in the term, so:
        ?- [X,Y|Z] = [1,2,3].
           X = 1
           Y = 2
           Z = [3]

Ok -- how do we do interesting things with lists. For example, how might we
"append" two lists ? Well, there is no "concatenation" or sticking
together. In prolog you write a predicate:

	append(X,Y,Z)

which is true if Z is the result of appending the lists X and Y.
Turns out such a predicate is built-in, so lets see what it does.

      ?- append([1,2],[3,4],Z).
        Z=[1,2,3,4]
	Yes

It simply "solves" for the right Z that happens to be the result of
appending [1,2] and [3,4], but wait, predicates can do more:

      ?- append(X,[3,4],[1,2,3,4]).
        X=[1,2]

whoa! backwards computation -- what X is such that when appended to [3,4]
you get [1,2,3,4] ? And now, the full power of multiple solutions:

      ?- append(X,Y,[1,2,3]).
        X = []
        Y = [1,2,3] ;

        X = [1]
        Y = [2,3] ;

        X = [1,2]
        Y = [3] ;

        X = [1,2,3]
        Y = []
        Yes

Try doing that in another language.

There are several such predicates for reverse, sort, append, built-in, but
lets try to roll our own.

  	How would you write append(X,Y,Z) in Prolog?

Well, the base case is that if X is empty then, Z is just Y.

      append([], Y, Y).         % base case

The recursive case is when X is of the form [H|Tx], in which case, Z must
begin with H, and the tail of Z is obtained by appending Tx to Y:

      append([H|T], Y, [H|Tz]) :- append(Tx,Y,Tz).     % recursive case

Very different way of thinking than imperative languages. Lets see what
happens with the query:
	 ?- append([1],[2],Z).

	 Prolog tries to prove the term append([1],[2],Z)
	 ---> recursive case fires.
	 H unifies to 1
	 Tx unifies to []
	 Y unifies to [2]
	 Z unifies to [1|Tz]
	   ---> prove:      append(Tx,Y,Tz)
	   ---> i.e. prove: append([], [2], Tz)
	   base case fires.
              ---> Tz unifies to [2]
              ---> therefore:  Z = [1,2]

But, because of the magic of pattern matching, proving and predicates, you
get the backwards computations by the same "proving" process !

Lets do a few more. Lets write a predicate tailof(X,Y) which is true if Y
is the tail of the list X.

	tailof([_|X],X).

Again, note the judicious use of the wildcard "_". If you actually named
the variable there, eg.

	tailof([H|X],X).

The compiler would warn you that you named a variable but used it only
once -- a "Singleton Variable".

Lets write a predicate which is true of lists with three or more elements:

    has3orMoreElements([_,_,_|_]).

What does this predicate do ?

    foo([X,_,_,_,X|_]).

One more tricky one. Lets write a predicate isin(X,L) which is true if
X is an element of the list L. How ?

base case: if X is the first element of the list L.

	isin(X,[X|_]).

recursive case: if X appears in the tail of the list L.

	isin(X,[_|T]) :- isin(X,T).

Let's give it a spin:

	?- isin(2,[1,2,3]).
	Yes

	?- isin(X,[1,2]).
	X=1 ;
	X=2 ;
	No

	?- isin(1,[2,3]).
	No


Let's write another predicate:

	mylength(L,X)

which is true if X is the length of list L

  mylength([],0).
  mylength([_|Tail],Len) :- mylength(Tail,TailLen),
		            Len is TailLen +1.

  ?- mylength([1,2],L).
     does not unify with  mylength([],0)
     unifies with mylength([_|Tail],Len) with the bindings:
            Tail = [2]  and Len = L

       now I need to prove the two things:
         mylength([2],TailLen)   and  Len is TailLen + 1

         can I prove the first one?
         mylength([2],TailLen)  does not unify with mylength([],0)
         mylength([2],TailLen)  unifies with  mylength([_|Tail'],Len')
               with the bindings:
	      Tail' = []   and Len' = TailLen

	    now I need to prove the two conditions:
              mylength([],TailLen'') and Len' is TailLen'' + 1
              can I prove the first one?
              mylength([],TailLen'') unifies with mylength([],0)
                 with the bindings:  TailLen'' = 0
              Len' is TailLen'' + 1  then leads to the binding
                 Len' = 1
              therefore TailLen is equal to Len', and thus to 1
            therefore Len is equal to Len' + 1, and thus to 2
          therefore L is equal to Len, and thus to 2
        Prolog answers L = 2.

----------------------------------- Cuts ----------------------------------

  - Ordering clauses and goals is a way to somewhat control the search and
    backtracking process, but it is very limited.
  - There is something called a "cut" that prevents Prolog from backtracking.
  - Example: Let's say we're writing a program to compute the following step function:
        X < 3   phi(X) = 0
   3 <= X < 6   phi(X) = 2        
   6 <= X       phi(X) = 4

  In Prolog we can implement this with a binary predicate, f(X,Y), which
  is true if Y is the function value at point X. For instance, f(0,0) is
  true, f(4,2) is true, but f(2,4) is false. Here is the program:

       f(X,0) :- X < 3.                  [rule 1]
       f(X,2) :- 3 =< X, X < 6.          [rule 2]     note '=<'
       f(X,4) :- 6 =< X.                 [rule 3]

  There are two sources of inefficiency in this program, that we'll see
  on one example:

     ?- f(1,Y), 2 < Y.      [find a Y such that Y = f(1)  and 2 < Y]  
                            [ we can see this is going to fail]

   what does Prolog do?

                    f(1,Y)
                    2 < Y ----------
         rule 1  /    \             \
         Y = 0  /      \  rule 2     \  rule 3
               /        | Y = 2       |  Y = 4
              |         |             |
            1 < 3      3 <= 1        6 <= 1
            2 < 0      1 < 6         2 < 4
             |         2 < 2          NO
             |         NO
            2 < 0      
             NO

   There is really no point in trying rule 2 and rule 3 because since X < 3, we
   know that rule 2 and rule 3 will fail. Basically, the three rules are mututally
   exclusive. We know that. Prolog doesn't.

   So, we can "cut" the backtracking by using the '!' operator:

       f(X,0) :- X < 3, !.   
       f(X,2) :- 3 <= X, X < 6, !.
       f(X,4) :- 6 <= X.      


   The new execution looks like:

                    f(1,Y)
                    2 < Y
         rule 1  /    
         Y = 0  /    
               /    
              |    
            1 < 3
            2 < 0
             |      
             CUT
             |   
            2 < 0      
             NO

    Lessons: cuts can be used to prevent Prolog from going into branches
             of the search tree that we know, due to our understanding and
             knowledge of the problem, will not succedd anyway.

  - There are many more things possible with cuts and using them well is
    an art. A program with no cuts at all will run orders of magnitude
    slower than an equivalent program with a few '!' thrown in.


-------------------------- Accumulators ---------------------------

  - There are cases in which you want to add an argument to a predicate
    just to keep track of useful information

Example: List Reverse:
----------------------

We will now write a predicate:

	rev(X,Y)

that is true if the list Y is the reverse of the list X.
To do so, we will use an accumulator that tracks the elements seen so far
in X.

	rev(X,Y) :- acc_rev(X,Y,[]).

The third parameter is the "accumulator". We will "push" elements into it
in the order they appear in X. Thus, when we have pushed all the elements,
the third parameter is the "reversed" version of X.

	acc_rev([],Y,Y).  %base case
	acc_rev([H|T],Y,SoFar) :- acc_rev(T,Y,[H|SoFar]). %recursive case


	?- rev([1,2,3],Y).
	Y = [3,2,1]
	Yes

	?- rev(X,[3,2,1]).
	X = 1,2,3
	Yes

The nice thing about predicates, is one can go forwards or backwards! Its
completely symmetric...




Example: Finding all solutions:
-------------------------------

Suppose we have a predicate foo(X), defined:

      foo(a).  
      foo(b).
      foo(c).
      foo(d).

and say we want to find all the terms X such that foo(X) is true.
We will use an accumulator to define a predicate:

	allfoos(L)

that is true for a list of terms iff every term in the list satisfies foo.


      allfoos(L) :- listallfoos(L,[]).

listallfoos is a helper predicate, whose second argument is an accumulator
that "tracks" which terms satisfying foo are already known. We shall then
"add" those terms that satisfy foo, but are not in the "accumulator".

      % recursive case
      listallfoos([X|L],SoFar) :- foo(X),    
                                  not(isin(X,SoFar)),
                                  append(SoFar,[X],NewSoFar),
                                  listallfoos(L,NewSoFar).
      % base case
      listallfoos([],_).    

      ?- allfoos(A).
        must prove listalllfoos(A,[]).
        unifies with listallfoos([X|L],[])
          must prove four things: foo(X)
                                  not(isin(X,[])
                                  append([],[X],NewSoFar)
                                  listallfoos(L,NewSoFar)
            foo(a) 			true   (X is bound to a)
            not(isin(a,[])) 		true
            append([],[a],NewSoFar)	true with NewSoFar=[a]
            must prove listallfoos(L,[a])
            unifies with liastallfoos([Y|L'],[a])
             must prove four things: foo(Y)
                                     not(isin(Y,[a]).
                                     append([a],[Y],NewSoFar')
                                     listallfoos(L',NewSoFar')
               foo(a)		  true
               not(isin(a,[a]))   false  BACKTRACK
               foo(b)		  true  (Y is bound to b)
	       not(isin(b,[b]))   true
               append([a],[b],NewSoFar')  true with NewSoFar' = [a,b]
               must prove listallfoos(L',[a,b])
               unifies with listallfoos([Z|L''],[a,b])
                 must prove four things: foo(Z)
                                         not(isin(Z,[a,b])
                 one can see that will fail   BACKTRACK
               unifies with listallfoos([],[a,b]).
               therefore: L' unifies with []
             therefore: [Y|L'] unifies with [b]
             therefore L unifies with [b]
             therefore [X|L] unifies with [a,b]
           therefore A unifies with [a,b]
         therefore  allfoos([a,b])

If you try this code, and hit ';', you'll get multiple answers
Try to figure out why (using the "trace" mode)
Solution: add a cut

      listallfoos_cut([X|L],SoFar) :-
            foo(X),    
            not(isin(X,SoFar)),
            append(SoFar,[X],NewSoFar),
            listallfoos(L,NewSoFar),!.

      listallfoos_cut([],_).

What happens when you flip order of base case and recursion ?

---------------------------- Puzzle Solving ----------------------------

We now have a good feel for what Prolog programs look like. Lets finish, by
seeing how succinctly and elegantly prolog allows us to write code to solve
tricky logical puzzles.


Towers of Hanoi:
---------------

                  |            |           |
                 =|=           |           |
               ===|===         |           |
             =====|=====       |	         |
	         =======|=======     |           |
       --------------------------------------------------		
		Peg 1        Peg 2       Peg 3

Puzzle: There are three pegs. On the first one, there is a stack of rings
of decreasing radius (that forms a tower).
In each step, you are allowed to move the top ring from one peg to another, but
only if the rings in the new peg form a conical tower -- i.e. as long as
the sequences of radii from top to bottom is increasing (as shown in the
figure).

  - Goal: Find the sequence of moves (move top ring from from peg X to peg Y)
          that moves the tower from peg 1 to peg 3.
  - The basic action is to move 1 disk, with printing

	move(A,B) :-
		nl, write ('Move topdisk from '),
                write(A), write(' to '), write(B).

  - the main predicate is transfer(N,A,B,X):
      represents "Move N disks from peg A to peg B by using peg X as a helper"
  - base case:
      transfer(1,A,B,X) :- move(A,B).
      Better written as: transfer(1,A,B,_) :- move(A,B).

  - inductive case:
     transfer(N,A,B,X) :-
		transfer the top N-1 disks to X
 	        transfer the (bottom) disk from A to B
                transfer the top N-1 disks from X to B

     transfer(N,A,B,X) :-
		M is N-1,
		transfer(M,A,X,B),
		move(A,B),
		transfer(M,X,B,A).

Lets see how these work -- lets name the pegs using atoms: peg1, peg2,
peg3. Here's the sequence of moves to transfer a tower of size 3 across
(you can try this at home!).


  ?- transfer(3,peg1,peg3,peg2).
    Move topdisk from peg1 to peg3
    Move topdisk from peg1 to peg2
    Move topdisk from peg3 to peg2
    Move topdisk from peg1 to peg3
    Move topdisk from peg2 to peg1
    Move topdisk from peg2 to peg3
    Move topdisk from peg1 to peg3




Farmer/ Wolf / Goat / Cabbage:
------------------------------

	 *West*              *East*

       Goat       |       |           Goat eats cabbage if no farmer
       Wolf       | river |           Wolf eats goat if no farmer
       Cabbage    |       |           Only one spot on the boat(farmer+1)

Configure the "state" of the program as a list with the location of the
four objects (farmer, wolf, goat, cabbage). There are two locations: West (w)
and East (e).

       initial state:        [w,w,w,w]

       desired state:        [e,e,e,e]

There are four kinds of moves:
	with the cabbage, (move_cabbage)
	with the goat,    (move_goat)
	with the wolf,    (move_wolf)
	with nothing.     (move_nothing)

Here is how the "state" changes with a given move:

For instance,   [w,w,w,w] ---"move wolf"--> [e,e,w,w]

We encode this as:

       move([w,w,w,w],move_wolf,[e,e,w,w]).

          (this just says that the state transformation above is true)

We could write all the possible moves as facts, but there would be a lot. However,
it is clear that when the farmer and wolf move, the goat and the cabbage do not
move, so a more general fact is:

       move([w,w,P_Goat,P_Cabbage],move_wolf,[e,e,P_Goat,P_Cabbage]).
       move([e,e,P_Goat,P_Cabbage],move_wolf,[w,w,P_Goat,P_Cabbage]).

therefore, a more general goal is:

       move([X,X,P_Goat,P_Cabbage],move_wolf,[Y,Y,P_Goat,P_Cabbage]) :- change(X,Y)

where we have:
                 change(e,w).
                 change(w,e).     

In addition to ensuring that X and Y are different, this predicate ensures
that they cannot be any random atom -- they must be either "e" or "w".

Now we can just write the whole program:

       move([X,X,P_Goat,P_Cabbage],move_wolf,[Y,Y,P_Goat,P_Cabbage]) :- change(X,Y).
       move([X,P_Wolf,X,P_Cabbage],move_goat,[Y,P_Wolf,Y,P_Cabbage]) :- change(X,Y).
       move([X,P_Wolf,P_Goat,X],move_cabbage,[Y,P_Wolf,P_Goat,Y]) :- change(X,Y).
       move([X,P_Wolf,P_Goat,P_Cabbage],move_nothing,[Y,P_Wolf,P_Goat,P_Cabbage]) :- change(X,Y).

At this point we have encoded all the possible moves. But there is nothing about
moves being safe or unsafe.  We need a safe predicate that takes a state as input and
is true if the state is sage (nobody eats nobody).

  "if at least one of the goat or the wolf is on the same bank as the farmer, AND
      at least one of the goat or cabbage is on the same bank as the farmer,
   then we're safe"

We define the one_equal(X,Y,Z) predicate that returns true if at least one
of Y or Z is equal to X:

    one_equal(X,X,_).
    one_equal(X,_,X).

then we can have:

     safe([P_Farmer,P_Wolf,P_Goat,P_Cabbage]) :-
         one_equal(P_Farmer,P_Goat,P_Wolf),
	 one_equal(P_Farmer,P_Goat,P_Cabbage).

this encodes the logical statement we made above.

A solution is defined as a sequence of moves such that we are either:
-- in the target configuration, all on the east bank, or,
-- in a state from which there is a single move, which takes us into
a safe state, from which we can get to the target configuration.

    solution([e,e,e,e],[]).
    solution(State,[FirstMove|RemainingMoves]) :-
       move(State,FirstMove,NextState),
       safe(NextState),
       solution(NextState,RemainingMoves).

The program is complete.

Example run:

If you just type solution([w,w,w,w],X), we get into an infinite loop as there are
infinitely solutions. So:

    ?- length(X,7), solution([w,w,w,w],X).

     X = [goat, nothing, wolf, goat, cabbage, nothing, goat]

In fact, 7 steps is the shortest solution.

    ?- length(X,12), solution([w,w,w,w],X).         (needs an odd number of moves)
     No

    ?- length(X,13423), solution([w,w,w,w],X).
     [goat, goat, goat, goat, goat, goat, goat, ....., +7 steps] is one of the solutions
