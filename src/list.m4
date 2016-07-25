m4_define([m4_list_declare], [_m4_list_declare([$1], m4_expand($[]1))])

m4_define([_m4_list_declare], [m4_do(
	[m4_define([$1_GET], [m4_expand([m4_list_nth([$1], [$2])])])],
	[m4_define([$1_FOREACH], [m4_if(m4_list_len([$1]),
		0, [],
		[m4_foreach([item], [m4_dquote_elt(m4_list_contents([$1]))], [m4_unquote($2)])])])],
)])

dnl
dnl $1: The list's ID
dnl $2, ... Items to be appended: DON'T QUOTE items too much before you add them, quotes will be escaped (m4_escape) and therefore ineffective in m4sugar!
m4_define([m4_list_add], [m4_do(
	[m4_for([idx], 2, $#, 1,
		[_m4_list_add_single($1, m4_argn(idx, $@))])],
)])

m4_define([_m4_list_add_single], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME,
		[m4_define(_LIST_NAME, m4_dquote(m4_escape([$2])))],
		[m4_define(_LIST_NAME, m4_quote(m4_list_contents([$1]),)m4_dquote(m4_escape([$2])))],
	)],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_len], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[],
	[m4_ifndef(_LIST_NAME, 0, [m4_count(m4_indir(_LIST_NAME))])],
	[m4_popdef([_LIST_NAME])],
)])

dnl
dnl Pefrorm an action if a given list is empty
dnl $1: The list's ID
dnl $2: The action to do if the list is empty or not even defined
dnl $3: The action to do if the list is defined and non-empty
m4_define([m4_list_ifempty], [m4_if(m4_list_len([$1]), 0, [$2], [$3])])

dnl
dnl Given a list name, it expands to its contents, suitable to use e.g. in m4_foreach
m4_define([m4_list_contents], [m4_do(
	[m4_if($#, 1, , [m4_fatal([$0: Expected exactly one argument, got $# instead (others were: ]m4_quote(m4_shift($@))[)])])],
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME, [], [m4_dquote_elt(m4_indir(_LIST_NAME))])],
	[m4_popdef([_LIST_NAME])],
)])

dnl	[m4_ifndef(_LIST_NAME, [], m4_expand([m4_dquote_elt(m4_indir(_LIST_NAME))]))],

dnl
dnl Given a list name and an element, it returns list of indices of the element in the list
dnl or nothing if it has not been found
m4_define([m4_list_contains], [m4_do(
	[m4_define([_FOUND_IDX], 0)],
	[m4_define([_FOUND_RESULT], [])],
	[m4_foreach([elem], [m4_list_contents([$1])], [m4_do(
		[m4_if(elem, [$2], [m4_define([_FOUND_RESULT], m4_expand([_FOUND_RESULT,_FOUND_IDX]))])],
		[m4_define([_FOUND_IDX], m4_incr(_FOUND_IDX))],
	)])],
	[m4_expand(m4_cdr(_FOUND_RESULT))],
	[m4_undefine([_FOUND_RESULT])],
	[m4_undefine([_FOUND_IDX])],
)])

m4_define([m4_list_sum], [m4_do(
	[m4_eval(m4_quote(m4_join(+, m4_unquote(m4_list_contents([$1])))))],
)])


dnl
dnl $1: list name
dnl $2: With what to join
dnl $3: left quote
dnl $4: right quote
dnl $5: last join
m4_define([m4_list_join], [m4_do(
	[m4_pushdef([listlen], m4_list_len([$1]))],
	[m4_if(m4_cmp(listlen - 2, 0), 1,
		[m4_for([idx], 1, m4_eval(listlen - 2), 1, [[$3]m4_list_nth([$1], idx)[$4$2]])],
	)],
	[m4_if(m4_cmp(listlen - 1, 0), 1,
		[[$3]m4_list_nth([$1], m4_decr(listlen))[$4]m4_default([$5], [$2])],
	)],
	[m4_if(m4_cmp(listlen - 0, 0), 1,
		[[$3]m4_list_nth([$1], listlen)[$4]],
	)],
	[m4_popdef([listlen])],
)])

dnl
dnl Returns its n-th element
m4_define([m4_list_nth], [m4_do(
	[m4_if(m4_cmp([$2], 0), 1, ,[m4_fatal([Requesting element $2 from list '$1': Only positive indices are available])])],
	[m4_pushdef([_listlen], m4_list_len([$1]))],
	[m4_if(m4_cmp([$2], _listlen), 1, [m4_fatal([The list '$1' has length of ]_listlen[, so element No. $2 is not available])])],
	[m4_popdef([_listlen])],
	[m4_expand(m4_argn([$2], m4_list_contents([$1])))],
)])

dnl
dnl The list loses its 1st element, which is also expanded by this macro.
m4_define([m4_list_pop_front], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_car(m4_unquote(_LIST_NAME))],
	[m4_define(_LIST_NAME, m4_cdr(m4_unquote(_LIST_NAME)))],
	[m4_popdef([_LIST_NAME])],
)])

dnl
dnl The list loses its last element, which is also expanded by this macro.
m4_define([m4_list_pop_back], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_list_pop_front([$1])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_destroy], [m4_undefine([_LIST_$1])])