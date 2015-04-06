(** * Lists: Working with Structured Data *)

Require Export Induction.

Module NatList. 

(* ###################################################### *)
(** * Pairs of Numbers *)

(** In an [Inductive] type definition, each constructor can take
    any number of arguments -- none (as with [true] and [O]), one (as
    with [S]), or more than one, as in this definition: *)

Inductive natprod : Type :=
  pair : nat -> nat -> natprod.

(** This declaration can be read: "There is just one way to
    construct a pair of numbers: by applying the constructor [pair] to
    two arguments of type [nat]." *)

(** We can construct an element of [natprod] like this: *)

Check (pair 3 5).

(** *** *)

(** Here are two simple function definitions for extracting the
    first and second components of a pair.  (The definitions also
    illustrate how to do pattern matching on two-argument
    constructors.) *)

Definition fst (p : natprod) : nat := 
  match p with
  | pair x y => x
  end.
Definition snd (p : natprod) : nat := 
  match p with
  | pair x y => y
  end.

Eval compute in (fst (pair 3 5)).
(* ===> 3 *)

(** *** *)

(** Since pairs are used quite a bit, it is nice to be able to
    write them with the standard mathematical notation [(x,y)] instead
    of [pair x y].  We can tell Coq to allow this with a [Notation]
    declaration. *)

Notation "( x , y )" := (pair x y).

(** The new notation can be used both in expressions and in
    pattern matches (indeed, we've seen it already in the previous
    chapter -- this notation is provided as part of the standard
    library): *)

Eval compute in (fst (3,5)).

Definition fst' (p : natprod) : nat := 
  match p with
  | (x,y) => x
  end.
Definition snd' (p : natprod) : nat := 
  match p with
  | (x,y) => y
  end.

Definition swap_pair (p : natprod) : natprod := 
  match p with
  | (x,y) => (y,x)
  end.

(** *** *)

(** Let's try and prove a few simple facts about pairs.  If we
    state the lemmas in a particular (and slightly peculiar) way, we
    can prove them with just reflexivity (and its built-in
    simplification): *)

Theorem surjective_pairing' : forall (n m : nat),
  (n,m) = (fst (n,m), snd (n,m)).
Proof.
  reflexivity.  Qed.

(** Note that [reflexivity] is not enough if we state the lemma in a
    more natural way: *)

Theorem surjective_pairing_stuck : forall (p : natprod),
  p = (fst p, snd p).
Proof.
  simpl. (* Doesn't reduce anything! *)
Abort.

(** *** *)
(** We have to expose the structure of [p] so that [simpl] can
    perform the pattern match in [fst] and [snd].  We can do this with
    [destruct].

    Notice that, unlike for [nat]s, [destruct] doesn't generate an
    extra subgoal here.  That's because [natprod]s can only be
    constructed in one way.  *)

Theorem surjective_pairing : forall (p : natprod),
  p = (fst p, snd p).
Proof.
  intros p.  destruct p as [n m].  simpl.  reflexivity.  Qed.

(** **** Exercise: 1 star (snd_fst_is_swap)  *)
Theorem snd_fst_is_swap : forall (p : natprod),
  (snd p, fst p) = swap_pair p.
Proof.
  intros. destruct p as [n m]. simpl. reflexivity.
Qed.
(** [] *)

(** **** Exercise: 1 star, optional (fst_swap_is_snd)  *)
Theorem fst_swap_is_snd : forall (p : natprod),
  fst (swap_pair p) = snd p.
Proof.
  intros. destruct p as [n m]. simpl. reflexivity. Qed.


(* ###################################################### *)
(** * Lists of Numbers *)

(** Generalizing the definition of pairs a little, we can
    describe the type of _lists_ of numbers like this: "A list is
    either the empty list or else a pair of a number and another
    list." *)

Inductive natlist : Type :=
  | nil : natlist
  | cons : nat -> natlist -> natlist.

(** For example, here is a three-element list: *)

Definition mylist := cons 1 (cons 2 (cons 3 nil)).


(** *** *)
(** As with pairs, it is more convenient to write lists in
    familiar programming notation.  The following two declarations
    allow us to use [::] as an infix [cons] operator and square
    brackets as an "outfix" notation for constructing lists. *)

Notation "x :: l" := (cons x l) (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).

(** It is not necessary to fully understand these declarations,
    but in case you are interested, here is roughly what's going on.

    The [right associativity] annotation tells Coq how to parenthesize
    expressions involving several uses of [::] so that, for example,
    the next three declarations mean exactly the same thing: *)

Definition mylist1 := 1 :: (2 :: (3 :: nil)).
Definition mylist2 := 1 :: 2 :: 3 :: nil.
Definition mylist3 := [1;2;3].

(** The [at level 60] part tells Coq how to parenthesize
    expressions that involve both [::] and some other infix operator.
    For example, since we defined [+] as infix notation for the [plus]
    function at level 50,
Notation "x + y" := (plus x y)  
                    (at level 50, left associativity).
   The [+] operator will bind tighter than [::], so [1 + 2 :: [3]]
   will be parsed, as we'd expect, as [(1 + 2) :: [3]] rather than [1
   + (2 :: [3])].

   (By the way, it's worth noting in passing that expressions like "[1
   + 2 :: [3]]" can be a little confusing when you read them in a .v
   file.  The inner brackets, around 3, indicate a list, but the outer
   brackets, which are invisible in the HTML rendering, are there to
   instruct the "coqdoc" tool that the bracketed part should be
   displayed as Coq code rather than running text.)

   The second and third [Notation] declarations above introduce the
   standard square-bracket notation for lists; the right-hand side of
   the third one illustrates Coq's syntax for declaring n-ary
   notations and translating them to nested sequences of binary
   constructors. *)

(** *** Repeat *)
(** A number of functions are useful for manipulating lists.
    For example, the [repeat] function takes a number [n] and a
    [count] and returns a list of length [count] where every element
    is [n]. *)

Fixpoint repeat (n count : nat) : natlist := 
  match count with
  | O => nil
  | S count' => n :: (repeat n count')
  end.

(** *** Length *)
(** The [length] function calculates the length of a list. *)

Fixpoint length (l:natlist) : nat := 
  match l with
  | nil => O
  | h :: t => S (length t)
  end.

(** *** Append *)
(** The [app] ("append") function concatenates two lists. *)

Fixpoint app (l1 l2 : natlist) : natlist := 
  match l1 with
  | nil    => l2
  | h :: t => h :: (app t l2)
  end.

(** Actually, [app] will be used a lot in some parts of what
    follows, so it is convenient to have an infix operator for it. *)

Notation "x ++ y" := (app x y) 
                     (right associativity, at level 60).

Example test_app1:             [1;2;3] ++ [4;5] = [1;2;3;4;5].
Proof. reflexivity.  Qed.
Example test_app2:             nil ++ [4;5] = [4;5].
Proof. reflexivity.  Qed.
Example test_app3:             [1;2;3] ++ nil = [1;2;3].
Proof. reflexivity.  Qed.

(** Here are two smaller examples of programming with lists.
    The [hd] function returns the first element (the "head") of the
    list, while [tl] returns everything but the first
    element (the "tail").  
    Of course, the empty list has no first element, so we
    must pass a default value to be returned in that case.  *)

(** *** Head (with default) and Tail *)
Definition hd (default:nat) (l:natlist) : nat :=
  match l with
  | nil => default
  | h :: t => h
  end.

Definition tl (l:natlist) : natlist :=
  match l with
  | nil => nil  
  | h :: t => t
  end.

Example test_hd1:             hd 0 [1;2;3] = 1.
Proof. reflexivity.  Qed.
Example test_hd2:             hd 0 [] = 0.
Proof. reflexivity.  Qed.
Example test_tl:              tl [1;2;3] = [2;3].
Proof. reflexivity.  Qed.

(** **** Exercise: 2 stars (list_funs)  *)
(** Complete the definitions of [nonzeros], [oddmembers] and
    [countoddmembers] below. Have a look at the tests to understand
    what these functions should do. *)

Fixpoint nonzeros (l:natlist) : natlist :=
  match l with
  | nil => []
  | 0 :: t => nonzeros t
  | h :: t => h :: nonzeros t
  end.

Example test_nonzeros:            nonzeros [0;1;0;2;3;0;0] = [1;2;3].
 reflexivity.
Qed.

Fixpoint oddmembers (l:natlist) : natlist :=
   match l with
  | nil => nil  
  | h :: t => if oddb h then h :: oddmembers t else oddmembers t
  end.

Example test_oddmembers:            oddmembers [0;1;0;2;3;0;0] = [1;3].
 reflexivity. Qed.

Fixpoint countoddmembers (l:natlist) : nat := length (oddmembers l).

Example test_countoddmembers1:    countoddmembers [1;0;3;1;4;5] = 4.
 reflexivity. Qed. 
Example test_countoddmembers2:    countoddmembers [0;2;4] = 0.
 reflexivity. Qed. 
Example test_countoddmembers3:    countoddmembers nil = 0.
 reflexivity. Qed.  

(** **** Exercise: 3 stars, advanced (alternate)  *)
(** Complete the definition of [alternate], which "zips up" two lists
    into one, alternating between elements taken from the first list
    and elements from the second.  See the tests below for more
    specific examples.

    Note: one natural and elegant way of writing [alternate] will fail
    to satisfy Coq's requirement that all [Fixpoint] definitions be
    "obviously terminating."  If you find yourself in this rut, look
    for a slightly more verbose solution that considers elements of
    both lists at the same time.  (One possible solution requires
    defining a new kind of pairs, but this is not the only way.)  *)


Fixpoint alternate (l1 l2 : natlist) : natlist :=
  match l1,l2 with
  | nil,nil  => nil
  | l1', nil => l1'
  | nil, l2' => l2'
  | h1::l1',h2::l2' => h1 :: h2 :: alternate l1' l2'   
  end.


Example test_alternate1:        alternate [1;2;3] [4;5;6] = [1;4;2;5;3;6].
 reflexivity. Qed.
Example test_alternate2:        alternate [1] [4;5;6] = [1;4;5;6].
 reflexivity. Qed.
Example test_alternate3:        alternate [1;2;3] [4] = [1;4;2;3].
 reflexivity. Qed.
Example test_alternate4:        alternate [] [20;30] = [20;30].
 reflexivity. Qed.

(* ###################################################### *)
(** ** Bags via Lists *)

(** A [bag] (or [multiset]) is like a set, but each element can appear
    multiple times instead of just once.  One reasonable
    implementation of bags is to represent a bag of numbers as a
    list. *)

Definition bag := natlist.  

(** **** Exercise: 3 stars (bag_functions)  *)
(** Complete the following definitions for the functions
    [count], [sum], [add], and [member] for bags. *)

Fixpoint foldl (A: Type) (f : nat -> A -> A) (def: A) (l: natlist) : A :=
   match l with
  | nil => def
  | h :: t => foldl A f (f h def) t
  end.

Fixpoint foldr (A: Type) (f : nat -> A -> A) (def: A) (l: natlist) : A :=
   match l with
  | nil => def
  | h :: t => f h (foldr A f def t)
  end.
  
Definition filter (f:nat->bool) (l:natlist) : natlist :=
  foldr natlist (fun n ns => if f n then n :: ns else ns) nil l.

Fixpoint count (v:nat) (s:bag) : nat := 
  match s with
  | nil  => 0
  | h::t => if beq_nat h v then 1 + count v t else count v t
 end.

(** All these proofs can be done just by [reflexivity]. *)

Example test_count1:              count 1 [1;2;3;1;4;1] = 3.
 reflexivity. Qed.
Example test_count2:              count 6 [1;2;3;1;4;1] = 0.
 reflexivity. Qed.

(** Multiset [sum] is similar to set [union]: [sum a b] contains
    all the elements of [a] and of [b].  (Mathematicians usually
    define [union] on multisets a little bit differently, which
    is why we don't use that name for this operation.)
    For [sum] we're giving you a header that does not give explicit
    names to the arguments.  Moreover, it uses the keyword
    [Definition] instead of [Fixpoint], so even if you had names for
    the arguments, you wouldn't be able to process them recursively.
    The point of stating the question this way is to encourage you to
    think about whether [sum] can be implemented in another way --
    perhaps by using functions that have already been defined.  *)

Definition sum : bag -> bag -> bag := app.

Example test_sum1:              count 1 (sum [1;2;3] [1;4;1]) = 3.
 reflexivity. Qed.

Definition add (v:nat) (s:bag) : bag := v :: s.
    
Example test_add1:                count 1 (add 1 [1;4;1]) = 3.
 reflexivity. Qed.
Example test_add2:                count 5 (add 1 [1;4;1]) = 0.
 reflexivity. Qed.

Fixpoint member (v:nat) (s:bag) : bool :=
  match s with
    | [] => false
    | h::t => if beq_nat v h then true else member v t
  end.                                            

Example test_member1:             member 1 [1;4;1] = true.
 reflexivity. Qed.
Example test_member2:             member 2 [1;4;1] = false.
 reflexivity. Qed.

(** **** Exercise: 3 stars, optional (bag_more_functions)  *)
(** Here are some more bag functions for you to practice with. *)

Fixpoint remove_one (v:nat) (s:bag) : bag :=
  match s with
  | nil => nil
  | h :: t => if beq_nat h v then t else h :: remove_one v t
  end.

  (* When remove_one is applied to a bag without the number to remove,
     it should return the same bag unchanged. *)

Example test_remove_one1:         count 5 (remove_one 5 [2;1;5;4;1]) = 0.
 reflexivity. Qed.
Example test_remove_one2:         count 5 (remove_one 5 [2;1;4;1]) = 0.
 reflexivity. Qed.
Example test_remove_one3:         count 4 (remove_one 5 [2;1;4;5;1;4]) = 2.
 reflexivity. Qed.
Example test_remove_one4:         count 5 (remove_one 5 [2;1;5;4;5;1;4]) = 1.
 reflexivity. Qed.

Fixpoint remove_all (v:nat) (s:bag) : bag := filter (fun n => negb (beq_nat v n)) s.

Example test_remove_all1:          count 5 (remove_all 5 [2;1;5;4;1]) = 0.
 reflexivity. Qed.
Example test_remove_all2:          count 5 (remove_all 5 [2;1;4;1]) = 0.
 reflexivity. Qed.
Example test_remove_all3:          count 4 (remove_all 5 [2;1;4;5;1;4]) = 2.
 reflexivity. Qed.
Example test_remove_all4:          count 5 (remove_all 5 [2;1;5;4;5;1;4;5;1;4]) = 0.
 reflexivity. Qed.

Fixpoint subset (s1:bag) (s2:bag) : bool :=
  match s1 with
  | [] => true
  | h :: t => if member h s2 then subset t (remove_one h s2) else false
  end.

Example test_subset1:              subset [1;2] [2;1;4;1] = true.
 reflexivity. Qed.
Example test_subset2:              subset [1;2;2] [2;1;4;1] = false.
 reflexivity. Qed.


(* ###################################################### *)
(** * Reasoning About Lists *)

(** Just as with numbers, simple facts about list-processing
    functions can sometimes be proved entirely by simplification. For
    example, the simplification performed by [reflexivity] is enough
    for this theorem... *)

Theorem nil_app : forall l:natlist,
  [] ++ l = l.
Proof. reflexivity. Qed.

(** ... because the [[]] is substituted into the match position
    in the definition of [app], allowing the match itself to be
    simplified. *)

(** Also, as with numbers, it is sometimes helpful to perform case
    analysis on the possible shapes (empty or non-empty) of an unknown
    list. *)

Theorem tl_length_pred : forall l:natlist,
  pred (length l) = length (tl l).
Proof.
  intros l. destruct l as [| n l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons n l'". 
    reflexivity.  Qed.

(** Here, the [nil] case works because we've chosen to define
    [tl nil = nil]. Notice that the [as] annotation on the [destruct]
    tactic here introduces two names, [n] and [l'], corresponding to
    the fact that the [cons] constructor for lists takes two
    arguments (the head and tail of the list it is constructing). *)

(** Usually, though, interesting theorems about lists require
    induction for their proofs. *)

(* ###################################################### *)
(** ** Micro-Sermon *)

(** Simply reading example proof scripts will not get you very far!
    It is very important to work through the details of each one,
    using Coq and thinking about what each step achieves.  Otherwise
    it is more or less guaranteed that the exercises will make no
    sense... *)

(* ###################################################### *)
(** ** Induction on Lists *)

(** Proofs by induction over datatypes like [natlist] are
    perhaps a little less familiar than standard natural number
    induction, but the basic idea is equally simple.  Each [Inductive]
    declaration defines a set of data values that can be built up from
    the declared constructors: a boolean can be either [true] or
    [false]; a number can be either [O] or [S] applied to a number; a
    list can be either [nil] or [cons] applied to a number and a list.

    Moreover, applications of the declared constructors to one another
    are the _only_ possible shapes that elements of an inductively
    defined set can have, and this fact directly gives rise to a way
    of reasoning about inductively defined sets: a number is either
    [O] or else it is [S] applied to some _smaller_ number; a list is
    either [nil] or else it is [cons] applied to some number and some
    _smaller_ list; etc. So, if we have in mind some proposition [P]
    that mentions a list [l] and we want to argue that [P] holds for
    _all_ lists, we can reason as follows:

      - First, show that [P] is true of [l] when [l] is [nil].

      - Then show that [P] is true of [l] when [l] is [cons n l'] for
        some number [n] and some smaller list [l'], assuming that [P]
        is true for [l'].

    Since larger lists can only be built up from smaller ones,
    eventually reaching [nil], these two things together establish the
    truth of [P] for all lists [l].  Here's a concrete example: *)

Theorem app_assoc : forall l1 l2 l3 : natlist, 
  (l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3).   
Proof.
  intros l1 l2 l3. induction l1 as [| n l1'].
  Case "l1 = nil".
    reflexivity.
  Case "l1 = cons n l1'".
    simpl. rewrite -> IHl1'. reflexivity.  Qed.

(** Again, this Coq proof is not especially illuminating as a
    static written document -- it is easy to see what's going on if
    you are reading the proof in an interactive Coq session and you
    can see the current goal and context at each point, but this state
    is not visible in the written-down parts of the Coq proof.  So a
    natural-language proof -- one written for human readers -- will
    need to include more explicit signposts; in particular, it will
    help the reader stay oriented if we remind them exactly what the
    induction hypothesis is in the second case.  *)

(** *** Informal version *)

(** _Theorem_: For all lists [l1], [l2], and [l3], 
   [(l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3)].

   _Proof_: By induction on [l1].

   - First, suppose [l1 = []].  We must show
       ([] ++ l2) ++ l3 = [] ++ (l2 ++ l3),
     which follows directly from the definition of [++].

   - Next, suppose [l1 = n::l1'], with
       (l1' ++ l2) ++ l3 = l1' ++ (l2 ++ l3)
     (the induction hypothesis). We must show
       ((n :: l1') ++ l2) ++ l3 = (n :: l1') ++ (l2 ++ l3).
]]  
     By the definition of [++], this follows from
       n :: ((l1' ++ l2) ++ l3) = n :: (l1' ++ (l2 ++ l3)),
     which is immediate from the induction hypothesis.  []
*)

(** *** Another example *)
(**
  Here is a similar example to be worked together in class: *)

Theorem app_length : forall l1 l2 : natlist, 
  length (l1 ++ l2) = (length l1) + (length l2).
Proof.
  (* WORKED IN CLASS *)
  intros l1 l2. induction l1 as [| n l1'].
  Case "l1 = nil".
    reflexivity.
  Case "l1 = cons".
    simpl. rewrite -> IHl1'. reflexivity.  Qed.


(** *** Reversing a list *)
(** For a slightly more involved example of an inductive proof
    over lists, suppose we define a "cons on the right" function
    [snoc] like this... *)

Fixpoint snoc (l:natlist) (v:nat) : natlist := 
  match l with
  | nil    => [v]
  | h :: t => h :: (snoc t v)
  end.

(** ... and use it to define a list-reversing function [rev]
    like this: *)

Fixpoint rev (l:natlist) : natlist := 
  match l with
  | nil    => nil
  | h :: t => snoc (rev t) h
  end.

Example test_rev1:            rev [1;2;3] = [3;2;1].
Proof. reflexivity.  Qed.
Example test_rev2:            rev nil = nil.
Proof. reflexivity.  Qed.

(** *** Proofs about reverse *)
(** Now let's prove some more list theorems using our newly
    defined [snoc] and [rev].  For something a little more challenging
    than the inductive proofs we've seen so far, let's prove that
    reversing a list does not change its length.  Our first attempt at
    this proof gets stuck in the successor case... *)

Theorem rev_length_firsttry : forall l : natlist,
  length (rev l) = length l.
Proof.
  intros l. induction l as [| n l'].
  Case "l = []".
    reflexivity.
  Case "l = n :: l'".
    (* This is the tricky case.  Let's begin as usual 
       by simplifying. *)
    simpl. 
    (* Now we seem to be stuck: the goal is an equality 
       involving [snoc], but we don't have any equations 
       in either the immediate context or the global 
       environment that have anything to do with [snoc]! 

       We can make a little progress by using the IH to 
       rewrite the goal... *)
    rewrite <- IHl'.
    (* ... but now we can't go any further. *)
Abort.

(** So let's take the equation about [snoc] that would have
    enabled us to make progress and prove it as a separate lemma. 
*)

Theorem length_snoc : forall n : nat, forall l : natlist,
  length (snoc l n) = S (length l).
Proof.
  intros n l. induction l as [| n' l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons n' l'".
    simpl. rewrite -> IHl'. reflexivity.  Qed. 

(**
    Note that we make the lemma as _general_ as possible: in particular,
    we quantify over _all_ [natlist]s, not just those that result
    from an application of [rev]. This should seem natural, 
    because the truth of the goal clearly doesn't depend on 
    the list having been reversed.  Moreover, it is much easier
    to prove the more general property. 
*)
    
(** Now we can complete the original proof. *)

Theorem rev_length : forall l : natlist,
  length (rev l) = length l.
Proof.
  intros l. induction l as [| n l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons".
    simpl. rewrite -> length_snoc. 
    rewrite -> IHl'. reflexivity.  Qed.

(** For comparison, here are informal proofs of these two theorems: 

    _Theorem_: For all numbers [n] and lists [l],
       [length (snoc l n) = S (length l)].
 
    _Proof_: By induction on [l].

    - First, suppose [l = []].  We must show
        length (snoc [] n) = S (length []),
      which follows directly from the definitions of
      [length] and [snoc].

    - Next, suppose [l = n'::l'], with
        length (snoc l' n) = S (length l').
      We must show
        length (snoc (n' :: l') n) = S (length (n' :: l')).
      By the definitions of [length] and [snoc], this
      follows from
        S (length (snoc l' n)) = S (S (length l')),
]] 
      which is immediate from the induction hypothesis. [] *)
                        
(** _Theorem_: For all lists [l], [length (rev l) = length l].
    
    _Proof_: By induction on [l].  

      - First, suppose [l = []].  We must show
          length (rev []) = length [],
        which follows directly from the definitions of [length] 
        and [rev].
    
      - Next, suppose [l = n::l'], with
          length (rev l') = length l'.
        We must show
          length (rev (n :: l')) = length (n :: l').
        By the definition of [rev], this follows from
          length (snoc (rev l') n) = S (length l')
        which, by the previous lemma, is the same as
          S (length (rev l')) = S (length l').
        This is immediate from the induction hypothesis. [] *)

(** Obviously, the style of these proofs is rather longwinded
    and pedantic.  After the first few, we might find it easier to
    follow proofs that give fewer details (since we can easily work
    them out in our own minds or on scratch paper if necessary) and
    just highlight the non-obvious steps.  In this more compressed
    style, the above proof might look more like this: *)

(** _Theorem_:
     For all lists [l], [length (rev l) = length l].

    _Proof_: First, observe that
       length (snoc l n) = S (length l)
     for any [l].  This follows by a straightforward induction on [l].
     The main property now follows by another straightforward
     induction on [l], using the observation together with the
     induction hypothesis in the case where [l = n'::l']. [] *)

(** Which style is preferable in a given situation depends on
    the sophistication of the expected audience and on how similar the
    proof at hand is to ones that the audience will already be
    familiar with.  The more pedantic style is a good default for
    present purposes. *)

(* ###################################################### *)
(** ** [SearchAbout] *)

(** We've seen that proofs can make use of other theorems we've
    already proved, using [rewrite], and later we will see other ways
    of reusing previous theorems.  But in order to refer to a theorem,
    we need to know its name, and remembering the names of all the
    theorems we might ever want to use can become quite difficult!  It
    is often hard even to remember what theorems have been proven,
    much less what they are named.

    Coq's [SearchAbout] command is quite helpful with this.  Typing
    [SearchAbout foo] will cause Coq to display a list of all theorems
    involving [foo].  For example, try uncommenting the following to
    see a list of theorems that we have proved about [rev]: *)

(*  SearchAbout rev. *)

(** Keep [SearchAbout] in mind as you do the following exercises and
    throughout the rest of the course; it can save you a lot of time! *)

(** Also, if you are using ProofGeneral, you can run [SearchAbout]
    with [C-c C-a C-a]. Pasting its response into your buffer can be
    accomplished with [C-c C-;]. *)

(* ###################################################### *)
(** ** List Exercises, Part 1 *)

(** **** Exercise: 3 stars (list_exercises)  *)
(** More practice with lists. *)

SearchAbout nil.

Theorem app_nil_end : forall l : natlist, 
  l ++ [] = l.   
Proof.
  intros. induction l. 
  reflexivity. 
  simpl. rewrite IHl. reflexivity.
Qed.

Theorem rev_involutive' : forall (n: nat) (l : natlist),
  rev (snoc l n) = n :: (rev l).
Proof.
  intros. induction l.
  reflexivity.
  simpl. rewrite IHl. simpl. reflexivity.
Admitted.

Theorem rev_involutive : forall l : natlist,
  rev (rev l) = l.
Proof.
  intros l. induction l as [| n l].
  reflexivity.
  simpl. rewrite rev_involutive'. rewrite IHl. reflexivity.
Qed.

(** There is a short solution to the next exercise.  If you find
    yourself getting tangled up, step back and try to look for a
    simpler way. *)

Theorem app_assoc4 : forall l1 l2 l3 l4 : natlist,
  l1 ++ (l2 ++ (l3 ++ l4)) = ((l1 ++ l2) ++ l3) ++ l4.
Proof.
  intros. rewrite app_assoc. rewrite app_assoc. reflexivity.
Qed.

Theorem snoc_append : forall (l:natlist) (n:nat),
  snoc l n = l ++ [n].
Proof.
  intros. induction l.
  reflexivity.
  simpl. rewrite IHl. reflexivity.
Qed.

Theorem distr_rev : forall l1 l2 : natlist,
  rev (l1 ++ l2) = (rev l2) ++ (rev l1).
Proof.
  intros.
  induction l1.
    simpl. rewrite app_nil_end. reflexivity.
    simpl. rewrite IHl1. rewrite snoc_append. rewrite snoc_append. rewrite app_assoc. reflexivity.
Qed.

(** An exercise about your implementation of [nonzeros]: *)

Lemma nonzeros_app : forall l1 l2 : natlist,
  nonzeros (l1 ++ l2) = (nonzeros l1) ++ (nonzeros l2).
Proof.
  intros. induction l1.
  simpl. reflexivity.
  destruct n.
    simpl. apply IHl1.
    simpl. rewrite <- IHl1. reflexivity.
Qed.

(** **** Exercise: 2 stars (beq_natlist)  *)
(** Fill in the definition of [beq_natlist], which compares
    lists of numbers for equality.  Prove that [beq_natlist l l]
    yields [true] for every list [l]. *)

Fixpoint beq_natlist (l1 l2 : natlist) : bool :=
  match l1,l2 with
    | [],[]   => true
    | _::_,[] => false
    | [],_::_ => false
    | h1::t1,h2::t2 => if beq_nat h1 h2 then beq_natlist t1 t2 else false
  end.

Example test_beq_natlist1 :   (beq_natlist nil nil = true).
 reflexivity. Qed.
Example test_beq_natlist2 :   beq_natlist [1;2;3] [1;2;3] = true.
 reflexivity. Qed.
Example test_beq_natlist3 :   beq_natlist [1;2;3] [1;2;4] = false.
 reflexivity. Qed.

Theorem beq_natlist_refl : forall l:natlist,
  true = beq_natlist l l.
Proof.
  intros. induction l.
  reflexivity.
  simpl. rewrite <- beq_nat_refl. rewrite IHl. reflexivity.
Qed.

(* ###################################################### *)
(** ** List Exercises, Part 2 *)

(** **** Exercise: 2 stars (list_design)  *)
(** Design exercise: 
     - Write down a non-trivial theorem [cons_snoc_app]
       involving [cons] ([::]), [snoc], and [app] ([++]).  
     - Prove it. *) 

(* FILL IN HERE *)
(** [] *)

(** **** Exercise: 3 stars, advanced (bag_proofs)  *)
(** Here are a couple of little theorems to prove about your
    definitions about bags earlier in the file. *)

Theorem count_member_nonzero : forall (s : bag),
  ble_nat 1 (count 1 (1 :: s)) = true.
Proof.
  intros. destruct s.
  reflexivity.
  simpl. reflexivity.
Qed.


(** The following lemma about [ble_nat] might help you in the next proof. *)

Theorem ble_n_Sn : forall n,
  ble_nat n (S n) = true.
Proof.
  intros n. induction n as [| n'].
  Case "0".  
    simpl.  reflexivity.
  Case "S n'".
    simpl.  rewrite IHn'.  reflexivity. 
Qed.

Theorem remove_decreases_count: forall (s : bag),
  ble_nat (count 0 (remove_one 0 s)) (count 0 s) = true.
Proof.
  intros. induction s.
  Case "[]". reflexivity.
  Case "non-empty".  
    simpl. destruct n. 
    SCase "n=0". simpl. rewrite ble_n_Sn. reflexivity.
    SCase "n>0". simpl. apply IHs.
Qed.
  

(** **** Exercise: 3 stars, optional (bag_count_sum)  *)  
(** Write down an interesting theorem [bag_count_sum] about bags 
    involving the functions [count] and [sum], and prove it.*)

(* FILL IN HERE *)
(** [] *)

(** **** Exercise: 4 stars, advanced (rev_injective)  *)
(** Prove that the [rev] function is injective, that is,

    forall (l1 l2 : natlist), rev l1 = rev l2 -> l1 = l2.

There is a hard way and an easy way to solve this exercise.
*)


Theorem nil_rev : [] = rev [].
Proof. intros. simpl. reflexivity. Qed.

Theorem f_equal : forall (A B : Type) (f: A -> B) (x y: A),
    x = y -> f x = f y.
Proof. intros A B f x y eq. rewrite eq.  reflexivity.  Qed.


Theorem snoc_not_nil: forall l n, [] = snoc l n -> false = true.
Proof. intros.
  destruct l. destruct n. inversion H. inversion H. inversion H.
Qed.
  
Theorem snoc_eq: forall l1 l2 n1 n2, snoc l1 n1 = snoc l2 n2 -> l1 = l2.
Proof. induction l1.
 Case "l1=[]".
   destruct l2.
     SCase "l2=[]". intros. reflexivity.
     SCase "l2=cons". intros. simpl in H. inversion H. apply snoc_not_nil in H2. inversion H2.
 Case "l2=cons".
   destruct l2.
     SCase "l2=[]". intros. simpl in H. inversion H. symmetry in H2. apply snoc_not_nil in H2. inversion H2.
     SCase "l2=cons". intros. simpl in H. inversion H. apply IHl1 in H2. rewrite H2. reflexivity.
Qed.      

Theorem snoc_eq': forall l1 n1 n2, snoc l1 n1 = snoc l1 n2 -> n1 = n2.
Proof. intros. induction l1.
 Case "l1=[]". intros. simpl in H. inversion H. reflexivity.
 Case "l1=cons". simpl in H. inversion H. apply IHl1 in H1. apply H1.
Qed.   
   
Theorem rev_length': forall (l1 l2: natlist),
   rev l1 = rev l2 -> length l1 = length l2.
Proof.
  intros l1. induction l1.
  Case "l1=[]".
    intros l2 rh.
    destruct l2.
    SCase "l2=[]". reflexivity.
    SCase "l2=cons". simpl in rh. apply snoc_not_nil in rh. inversion rh.
  Case "l1=cons".
    intros l2 rh.    
    destruct l2.
    SCase "l2=[]". simpl in rh.
      assert (H: forall n l, snoc l n = [] -> true = false).
        intros. induction l. inversion H. inversion H.
      apply H in rh. inversion rh.
    SCase "l2=cons". simpl. apply f_equal. apply IHl1. simpl in rh. apply snoc_eq in rh. apply rh.
Qed. 

Theorem peel_cons: forall n1 n2 l1 l2, n1 :: l1 = n2 :: l2 -> l1 = l2.
Proof. intros. destruct n1. destruct n2. inversion H. reflexivity. inversion H. inversion H. reflexivity.
Qed.

Theorem l_is_not_Sn_l: forall n l, l = n :: l -> False.
Proof. intros. induction l. inversion H. inversion H. apply IHl in H2. apply H2.
Qed.       
                 
Theorem Snoc_0_Sn_False: forall l1 l2 n, snoc l1 0 = snoc l2 (S n) -> False.
Proof.
  intros l1. induction l1.
  Case "l1=[]".
    intros.
    destruct l2.
      SCase "l2=[]". inversion H.
      SCase "l2=cons". simpl in H. apply peel_cons in H. apply snoc_not_nil in H.  inversion H.
  Case "l1=cons".
    intros.     
    simpl in H.
    destruct l2.
      SCase "l2=[]". simpl in H. inversion H. symmetry in H2. apply snoc_not_nil in H2. inversion H2.
      SCase "l2=cons". simpl in H. simpl in IHl1. inversion H. apply IHl1 in H2. apply H2.
Qed.

Theorem rev_injective: forall (l1 l2 : natlist), 
  rev l1 = rev l2 -> l1 = l2.
Proof. intros l1.
  induction l1. intros l2 H.   
    Case "[]". apply rev_length' in H. simpl in H.
      assert (H2: forall l, 0 = length l -> [] = l).
        intros. destruct l. reflexivity. simpl in H0. inversion H0.
      apply H2. apply H.
    Case "h::t".
      intros. destruct l2.
      SCase "l2=[]". simpl in H. symmetry in H. apply snoc_not_nil in H. inversion H.
      SCase "l2=cons". simpl in H.
      destruct n.
      SSCase "n=0".
        destruct n0.
        SSSCase "n0=0". apply f_equal. apply IHl1. apply snoc_eq in H. apply H.
        SSSCase "n0>0". apply Snoc_0_Sn_False in H. inversion H.
      SSCase "n>0".
        destruct n0.
        SSSCase "n0=0". symmetry in H. apply Snoc_0_Sn_False in H. inversion H.
        SSSCase "n0>0".
          inversion H. apply snoc_eq in H. rewrite H in H1.
          apply snoc_eq' in H1. inversion H1. apply f_equal. apply IHl1. apply H.
Qed.        


(* ###################################################### *)
(** * Options *)


(** One use of [natoption] is as a way of returning "error
    codes" from functions.  For example, suppose we want to write a
    function that returns the [n]th element of some list.  If we give
    it type [nat -> natlist -> nat], then we'll have to return some
    number when the list is too short! *)

Fixpoint index_bad (n:nat) (l:natlist) : nat :=
  match l with
  | nil => 42  (* arbitrary! *)
  | a :: l' => match beq_nat n O with 
               | true => a 
               | false => index_bad (pred n) l' 
               end
  end.

(** *** *)
(** On the other hand, if we give it type [nat -> natlist ->
    natoption], then we can return [None] when the list is too short
    and [Some a] when the list has enough members and [a] appears at
    position [n]. *)

Inductive natoption : Type :=
  | Some : nat -> natoption
  | None : natoption.  


Fixpoint index (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None 
  | a :: l' => match beq_nat n O with 
               | true => Some a
               | false => index (pred n) l' 
               end
  end.

Example test_index1 :    index 0 [4;5;6;7]  = Some 4.
Proof. reflexivity.  Qed.
Example test_index2 :    index 3 [4;5;6;7]  = Some 7.
Proof. reflexivity.  Qed.
Example test_index3 :    index 10 [4;5;6;7] = None.
Proof. reflexivity.  Qed.

(** This example is also an opportunity to introduce one more
    small feature of Coq's programming language: conditional
    expressions... *)

(** *** *)

Fixpoint index' (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None 
  | a :: l' => if beq_nat n O then Some a else index' (pred n) l'
  end.

(** Coq's conditionals are exactly like those found in any other
    language, with one small generalization.  Since the boolean type
    is not built in, Coq actually allows conditional expressions over
    _any_ inductively defined type with exactly two constructors.  The
    guard is considered true if it evaluates to the first constructor
    in the [Inductive] definition and false if it evaluates to the
    second. *)

(** The function below pulls the [nat] out of a [natoption], returning
    a supplied default in the [None] case. *)

Definition option_elim (d : nat) (o : natoption) : nat :=
  match o with
  | Some n' => n'
  | None => d
  end.

(** **** Exercise: 2 stars (hd_opt)  *)
(** Using the same idea, fix the [hd] function from earlier so we don't
   have to pass a default element for the [nil] case.  *)

Definition hd_opt (l : natlist) : natoption :=
  match l with
  | [] => None
  | h::t => Some h
  end.

Example test_hd_opt1 : hd_opt [] = None.
 reflexivity. Qed.

Example test_hd_opt2 : hd_opt [1] = Some 1.
 reflexivity. Qed.

Example test_hd_opt3 : hd_opt [5;6] = Some 5.
 reflexivity. Qed.
(** [] *)

(** **** Exercise: 1 star, optional (option_elim_hd)  *)
(** This exercise relates your new [hd_opt] to the old [hd]. *)

Theorem option_elim_hd : forall (l:natlist) (default:nat),
  hd default l = option_elim default (hd_opt l).
Proof.
  intros. destruct l.
    simpl. reflexivity.
    simpl. reflexivity.
Qed.

(* ###################################################### *)
(** * Dictionaries *)

(** As a final illustration of how fundamental data structures
    can be defined in Coq, here is the declaration of a simple
    [dictionary] data type, using numbers for both the keys and the
    values stored under these keys.  (That is, a dictionary represents
    a finite map from numbers to numbers.) *)

Module Dictionary.

Inductive dictionary : Type :=
  | empty  : dictionary 
  | record : nat -> nat -> dictionary -> dictionary. 

(** This declaration can be read: "There are two ways to construct a
    [dictionary]: either using the constructor [empty] to represent an
    empty dictionary, or by applying the constructor [record] to
    a key, a value, and an existing [dictionary] to construct a
    [dictionary] with an additional key to value mapping." *)

Definition insert (key value : nat) (d : dictionary) : dictionary :=
  (record key value d).

(** Here is a function [find] that searches a [dictionary] for a
    given key.  It evaluates evaluates to [None] if the key was not
    found and [Some val] if the key was mapped to [val] in the
    dictionary. If the same key is mapped to multiple values, [find]
    will return the first one it finds. *)

Fixpoint find (key : nat) (d : dictionary) : natoption := 
  match d with 
  | empty         => None
  | record k v d' => if (beq_nat key k) 
                       then (Some v) 
                       else (find key d')
  end.

(** **** Exercise: 1 star (dictionary_invariant1)  *)
(** Complete the following proof. *)

Theorem dictionary_invariant1' : forall (d : dictionary) (k v: nat),
  (find k (insert k v d)) = Some v.
Proof.
  intros. destruct d. 
    Case "[]". simpl. rewrite <- beq_nat_refl. reflexivity.
    Case "h::t". simpl. rewrite <- beq_nat_refl. reflexivity.
Qed.
 
(** **** Exercise: 1 star (dictionary_invariant2)  *)
(** Complete the following proof. *)

Theorem dictionary_invariant2' : forall (d : dictionary) (m n o: nat),
  beq_nat m n = false -> find m d = find m (insert n o d).
Proof.
  intros. destruct d.
    simpl. rewrite H. reflexivity.
    simpl. rewrite H. reflexivity.
Qed.

End Dictionary.


(** **** Exercise: 3 stars (bag_theorem)  *)
(** Write down an interesting theorem [bag_theorem] about bags involving
    the functions [count] and [add], and prove it.  Note that, since this
    problem is somewhat open-ended, it's possible that you may come up
    with a theorem which is true, but whose proof requires techniques
    you haven't learned yet.  Feel free to ask for help if you get
    stuck! *)

Definition bneq_nat (n m : nat) : bool := negb (beq_nat n m).

Definition bgt_nat (n m : nat) : bool := negb (ble_nat n m).

Theorem filter_nil_is_nil : forall (f:nat->bool),
  filter f [] = [].
Proof.
  intros.
  unfold filter. simpl.
  reflexivity.
Qed.

Theorem count_n_nil_false : forall (n: nat),
  count n [] = 0.
Proof.
  intros. unfold count. reflexivity.
Qed.

Theorem member_n_nil_false : forall (n: nat),
  member n [] = false.
Proof.
  intros. reflexivity.
Qed.

Theorem member_0_Sn_false : forall n, member 0 [S n] = false.
Proof. intros. destruct n.
  unfold member. simpl. reflexivity.
  unfold member. simpl. reflexivity.
Qed.
  
Theorem member_n_in_m_false : forall (n m: nat),
  beq_nat n m = false -> member n [m] = false.
Proof.
  intros n. induction n. 
  Case "n=0".
    destruct m.
    intros H. inversion H.
    intros H. unfold member. simpl. reflexivity.
  Case "n>0".
    destruct m.
    intros H. unfold member. simpl. reflexivity.
    intros H. apply IHn. inversion H. reflexivity.
Qed.
    
Theorem obvious_member : forall (n: nat) (s: bag),
  member n (n :: s) = true.
Proof.
  intros.
  unfold member. simpl. rewrite <- beq_nat_refl.  reflexivity. 
Qed.

Theorem bgt_nat_0_Sn_false : forall (n: nat),
  bgt_nat 0 (S n) = false.
Proof.
  intros. induction n.
  Case "0". reflexivity.
  Case "S n". unfold bgt_nat. simpl. reflexivity.
Qed.

Theorem bgt_nat_Sn_0_true : forall (n: nat),
  bgt_nat (S n) 0 = true.
Proof.
  intros. induction n.
  Case "0". reflexivity.
  Case "S n". unfold bgt_nat. simpl. reflexivity.
Qed.

Theorem flip_bool : forall b, b = true -> negb b = false.
Proof. intros. destruct b. reflexivity. inversion H. Qed.

Theorem kill_if : forall b : bool, (if b then true else false) = b.
Proof. intros. destruct b. reflexivity. reflexivity. Qed.

Theorem member_in_singleton : forall n m,
  member n [m] = true -> beq_nat n m = true.
Proof.
  induction m.
  simpl. destruct n. simpl. reflexivity. simpl. intros. inversion H.
  simpl. destruct n. simpl. intros. inversion H. simpl. intros.
  rewrite kill_if in H. apply H.
Qed.

Theorem b_and_neg_b: forall b, andb b (negb b) = false.
Proof. intros. destruct b. reflexivity. reflexivity.
Qed.

Theorem negb_and_b: forall b, andb (negb b) b = false.
Proof. intros. destruct b. reflexivity. reflexivity.
Qed.

Theorem beq_nat_add_S: forall n m, beq_nat n m = true -> beq_nat (S n) (S m) = true.
Proof. intros. simpl. apply H. Qed.

Theorem member_strip_S : forall n m, member (S n) [S m] = member n [m].
Proof. intros. destruct n. destruct m. reflexivity. reflexivity. reflexivity.
Qed.       
  
Theorem if_branches_both_true: forall b : bool, (if b then true else true) = true.
Proof. destruct b. reflexivity. reflexivity. Qed.

Theorem member_in_tail : forall (n m : nat) (l : bag),
  beq_nat n m        = false -> 
  member n (m :: l)  = true ->
  member n l         = true.
Proof. intros n m l neq mem. induction l.
  Case "[]".
   destruct n. destruct m.
   inversion neq.
   inversion mem.
   apply member_in_singleton in mem. rewrite neq in mem. inversion mem.   
  Case "cons".
    destruct (beq_nat n n0) eqn:H.
    SCase "true".  unfold member. rewrite H. reflexivity.
    SCase "false".
      unfold member. rewrite H. fold member. apply IHl.
      unfold member in mem. rewrite neq in mem. rewrite H in mem.
      fold member in mem. unfold member. rewrite neq. fold member. apply mem.
Qed.

Theorem imp: false = true -> true = true.
Proof. intros. reflexivity. Qed.

Theorem beq_nat_comm : forall (n m : nat),
  beq_nat n m = beq_nat m n.
Proof.
  intros n. induction n as [| n'].
  Case "n = O". simpl. intros m. destruct m as [| m'].
    SCase "m = O". reflexivity.
    SCase "m = S m'". reflexivity. 
  Case "n = S n'". 
    (* Notice that both the goal and the induction
       hypothesis have changed: the goal asks us to prove
       something more general (i.e., to prove the
       statement for _every_ [m]), but the IH is
       correspondingly more flexible, allowing us to
       choose any [m] we like when we apply the IH.  *)
    intros m.
    (* Now we choose a particular [m] and introduce the
       assumption that [double n = double m].  Since we
       are doing a case analysis on [n], we need a case
       analysis on [m] to keep the two "in sync." *)
    destruct m as [| m'].
    SCase "m = O". 
      (* The 0 case is trivial *)
      simpl. reflexivity.
    SCase "m = S m'".  
      (* At this point, since we are in the second
         branch of the [destruct m], the [m'] mentioned
         in the context at this point is actually the
         predecessor of the one we started out talking
         about.  Since we are also in the [S] branch of
         the induction, this is perfect: if we
         instantiate the generic [m] in the IH with the
         [m'] that we are talking about right now (this
         instantiation is performed automatically by
         [apply]), then [IHn'] gives us exactly what we
         need to finish the proof. *)
    apply IHn'.
Qed.      
  
(* this uses add, because add=cons and remove_one uses cons. *)
Theorem something_with_count_and_add : forall (n: nat) (s : bag),
  member n s = true ->
  count n s = count n (n :: remove_one n s).
Proof.
  intros n s H. induction s.
  Case "[]". rewrite member_n_nil_false in H. inversion H.
  Case "h::t". simpl. rewrite <- beq_nat_refl.
    destruct n. 
      SCase "n = 0".
        destruct n0.
        SSCase "n0 = 0". simpl. reflexivity.
        SSCase "n0 = S _". simpl. simpl in IHs. apply IHs. simpl in H. apply H.
      SCase "n > 0".
        destruct n0.
        SSCase "n0 = 0".   simpl. simpl in IHs. simpl in H. rewrite H in IHs. rewrite <- beq_nat_refl in IHs. apply IHs. reflexivity.
        SSCase "n0 = S _". simpl. simpl in H.
          destruct (beq_nat n n0) eqn:H2.
          SSSCase "true".  rewrite beq_nat_comm in H2. rewrite H2. reflexivity.
          SSSCase "false".
            rewrite beq_nat_comm in H2. rewrite H2. simpl.
            rewrite H2. simpl in IHs. rewrite <- beq_nat_refl in IHs.
            apply IHs. apply H.
Qed.       
          

End NatList.

(** $Date: 2014-12-31 11:17:56 -0500 (Wed, 31 Dec 2014) $ *)

