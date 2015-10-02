#!/usr/bin/perl -w

#bidirectional_hit_filter.pl
#Generated using perl_script_template.pl 1.33
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Created on 4/22/2008
#Center for Computational Research
#Copyright 2007

#                    GNU GENERAL PUBLIC LICENSE
#                       Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#
#                            Preamble
#
#  The GNU General Public License is a free, copyleft license for
#software and other kinds of works.
#
#  The licenses for most software and other practical works are designed
#to take away your freedom to share and change the works.  By contrast,
#the GNU General Public License is intended to guarantee your freedom to
#share and change all versions of a program--to make sure it remains free
#software for all its users.  We, the Free Software Foundation, use the
#GNU General Public License for most of our software; it applies also to
#any other work released this way by its authors.  You can apply it to
#your programs, too.
#
#  When we speak of free software, we are referring to freedom, not
#price.  Our General Public Licenses are designed to make sure that you
#have the freedom to distribute copies of free software (and charge for
#them if you wish), that you receive source code or can get it if you
#want it, that you can change the software or use pieces of it in new
#free programs, and that you know you can do these things.
#
#  To protect your rights, we need to prevent others from denying you
#these rights or asking you to surrender the rights.  Therefore, you have
#certain responsibilities if you distribute copies of the software, or if
#you modify it: responsibilities to respect the freedom of others.
#
#  For example, if you distribute copies of such a program, whether
#gratis or for a fee, you must pass on to the recipients the same
#freedoms that you received.  You must make sure that they, too, receive
#or can get the source code.  And you must show them these terms so they
#know their rights.
#
#  Developers that use the GNU GPL protect your rights with two steps:
#(1) assert copyright on the software, and (2) offer you this License
#giving you legal permission to copy, distribute and/or modify it.
#
#  For the developers' and authors' protection, the GPL clearly explains
#that there is no warranty for this free software.  For both users' and
#authors' sake, the GPL requires that modified versions be marked as
#changed, so that their problems will not be attributed erroneously to
#authors of previous versions.
#
#  Some devices are designed to deny users access to install or run
#modified versions of the software inside them, although the manufacturer
#can do so.  This is fundamentally incompatible with the aim of
#protecting users' freedom to change the software.  The systematic
#pattern of such abuse occurs in the area of products for individuals to
#use, which is precisely where it is most unacceptable.  Therefore, we
#have designed this version of the GPL to prohibit the practice for those
#products.  If such problems arise substantially in other domains, we
#stand ready to extend this provision to those domains in future versions
#of the GPL, as needed to protect the freedom of users.
#
#  Finally, every program is threatened constantly by software patents.
#States should not allow patents to restrict development and use of
#software on general-purpose computers, but in those that do, we wish to
#avoid the special danger that patents applied to a free program could
#make it effectively proprietary.  To prevent this, the GPL assures that
#patents cannot be used to render the program non-free.
#
#  The precise terms and conditions for copying, distribution and
#modification follow.
#
#                       TERMS AND CONDITIONS
#
#  0. Definitions.
#
#  "This License" refers to version 3 of the GNU General Public License.
#
#  "Copyright" also means copyright-like laws that apply to other kinds of
#works, such as semiconductor masks.
#
#  "The Program" refers to any copyrightable work licensed under this
#License.  Each licensee is addressed as "you".  "Licensees" and
#"recipients" may be individuals or organizations.
#
#  To "modify" a work means to copy from or adapt all or part of the work
#in a fashion requiring copyright permission, other than the making of an
#exact copy.  The resulting work is called a "modified version" of the
#earlier work or a work "based on" the earlier work.
#
#  A "covered work" means either the unmodified Program or a work based
#on the Program.
#
#  To "propagate" a work means to do anything with it that, without
#permission, would make you directly or secondarily liable for
#infringement under applicable copyright law, except executing it on a
#computer or modifying a private copy.  Propagation includes copying,
#distribution (with or without modification), making available to the
#public, and in some countries other activities as well.
#
#  To "convey" a work means any kind of propagation that enables other
#parties to make or receive copies.  Mere interaction with a user through
#a computer network, with no transfer of a copy, is not conveying.
#
#  An interactive user interface displays "Appropriate Legal Notices"
#to the extent that it includes a convenient and prominently visible
#feature that (1) displays an appropriate copyright notice, and (2)
#tells the user that there is no warranty for the work (except to the
#extent that warranties are provided), that licensees may convey the
#work under this License, and how to view a copy of this License.  If
#the interface presents a list of user commands or options, such as a
#menu, a prominent item in the list meets this criterion.
#
#  1. Source Code.
#
#  The "source code" for a work means the preferred form of the work
#for making modifications to it.  "Object code" means any non-source
#form of a work.
#
#  A "Standard Interface" means an interface that either is an official
#standard defined by a recognized standards body, or, in the case of
#interfaces specified for a particular programming language, one that
#is widely used among developers working in that language.
#
#  The "System Libraries" of an executable work include anything, other
#than the work as a whole, that (a) is included in the normal form of
#packaging a Major Component, but which is not part of that Major
#Component, and (b) serves only to enable use of the work with that
#Major Component, or to implement a Standard Interface for which an
#implementation is available to the public in source code form.  A
#"Major Component", in this context, means a major essential component
#(kernel, window system, and so on) of the specific operating system
#(if any) on which the executable work runs, or a compiler used to
#produce the work, or an object code interpreter used to run it.
#
#  The "Corresponding Source" for a work in object code form means all
#the source code needed to generate, install, and (for an executable
#work) run the object code and to modify the work, including scripts to
#control those activities.  However, it does not include the work's
#System Libraries, or general-purpose tools or generally available free
#programs which are used unmodified in performing those activities but
#which are not part of the work.  For example, Corresponding Source
#includes interface definition files associated with source files for
#the work, and the source code for shared libraries and dynamically
#linked subprograms that the work is specifically designed to require,
#such as by intimate data communication or control flow between those
#subprograms and other parts of the work.
#
#  The Corresponding Source need not include anything that users
#can regenerate automatically from other parts of the Corresponding
#Source.
#
#  The Corresponding Source for a work in source code form is that
#same work.
#
#  2. Basic Permissions.
#
#  All rights granted under this License are granted for the term of
#copyright on the Program, and are irrevocable provided the stated
#conditions are met.  This License explicitly affirms your unlimited
#permission to run the unmodified Program.  The output from running a
#covered work is covered by this License only if the output, given its
#content, constitutes a covered work.  This License acknowledges your
#rights of fair use or other equivalent, as provided by copyright law.
#
#  You may make, run and propagate covered works that you do not
#convey, without conditions so long as your license otherwise remains
#in force.  You may convey covered works to others for the sole purpose
#of having them make modifications exclusively for you, or provide you
#with facilities for running those works, provided that you comply with
#the terms of this License in conveying all material for which you do
#not control copyright.  Those thus making or running the covered works
#for you must do so exclusively on your behalf, under your direction
#and control, on terms that prohibit them from making any copies of
#your copyrighted material outside their relationship with you.
#
#  Conveying under any other circumstances is permitted solely under
#the conditions stated below.  Sublicensing is not allowed; section 10
#makes it unnecessary.
#
#  3. Protecting Users' Legal Rights From Anti-Circumvention Law.
#
#  No covered work shall be deemed part of an effective technological
#measure under any applicable law fulfilling obligations under article
#11 of the WIPO copyright treaty adopted on 20 December 1996, or
#similar laws prohibiting or restricting circumvention of such
#measures.
#
#  When you convey a covered work, you waive any legal power to forbid
#circumvention of technological measures to the extent such circumvention
#is effected by exercising rights under this License with respect to
#the covered work, and you disclaim any intention to limit operation or
#modification of the work as a means of enforcing, against the work's
#users, your or third parties' legal rights to forbid circumvention of
#technological measures.
#
#  4. Conveying Verbatim Copies.
#
#  You may convey verbatim copies of the Program's source code as you
#receive it, in any medium, provided that you conspicuously and
#appropriately publish on each copy an appropriate copyright notice;
#keep intact all notices stating that this License and any
#non-permissive terms added in accord with section 7 apply to the code;
#keep intact all notices of the absence of any warranty; and give all
#recipients a copy of this License along with the Program.
#
#  You may charge any price or no price for each copy that you convey,
#and you may offer support or warranty protection for a fee.
#
#  5. Conveying Modified Source Versions.
#
#  You may convey a work based on the Program, or the modifications to
#produce it from the Program, in the form of source code under the
#terms of section 4, provided that you also meet all of these conditions:
#
#    a) The work must carry prominent notices stating that you modified
#    it, and giving a relevant date.
#
#    b) The work must carry prominent notices stating that it is
#    released under this License and any conditions added under section
#    7.  This requirement modifies the requirement in section 4 to
#    "keep intact all notices".
#
#    c) You must license the entire work, as a whole, under this
#    License to anyone who comes into possession of a copy.  This
#    License will therefore apply, along with any applicable section 7
#    additional terms, to the whole of the work, and all its parts,
#    regardless of how they are packaged.  This License gives no
#    permission to license the work in any other way, but it does not
#    invalidate such permission if you have separately received it.
#
#    d) If the work has interactive user interfaces, each must display
#    Appropriate Legal Notices; however, if the Program has interactive
#    interfaces that do not display Appropriate Legal Notices, your
#    work need not make them do so.
#
#  A compilation of a covered work with other separate and independent
#works, which are not by their nature extensions of the covered work,
#and which are not combined with it such as to form a larger program,
#in or on a volume of a storage or distribution medium, is called an
#"aggregate" if the compilation and its resulting copyright are not
#used to limit the access or legal rights of the compilation's users
#beyond what the individual works permit.  Inclusion of a covered work
#in an aggregate does not cause this License to apply to the other
#parts of the aggregate.
#
#  6. Conveying Non-Source Forms.
#
#  You may convey a covered work in object code form under the terms
#of sections 4 and 5, provided that you also convey the
#machine-readable Corresponding Source under the terms of this License,
#in one of these ways:
#
#    a) Convey the object code in, or embodied in, a physical product
#    (including a physical distribution medium), accompanied by the
#    Corresponding Source fixed on a durable physical medium
#    customarily used for software interchange.
#
#    b) Convey the object code in, or embodied in, a physical product
#    (including a physical distribution medium), accompanied by a
#    written offer, valid for at least three years and valid for as
#    long as you offer spare parts or customer support for that product
#    model, to give anyone who possesses the object code either (1) a
#    copy of the Corresponding Source for all the software in the
#    product that is covered by this License, on a durable physical
#    medium customarily used for software interchange, for a price no
#    more than your reasonable cost of physically performing this
#    conveying of source, or (2) access to copy the
#    Corresponding Source from a network server at no charge.
#
#    c) Convey individual copies of the object code with a copy of the
#    written offer to provide the Corresponding Source.  This
#    alternative is allowed only occasionally and noncommercially, and
#    only if you received the object code with such an offer, in accord
#    with subsection 6b.
#
#    d) Convey the object code by offering access from a designated
#    place (gratis or for a charge), and offer equivalent access to the
#    Corresponding Source in the same way through the same place at no
#    further charge.  You need not require recipients to copy the
#    Corresponding Source along with the object code.  If the place to
#    copy the object code is a network server, the Corresponding Source
#    may be on a different server (operated by you or a third party)
#    that supports equivalent copying facilities, provided you maintain
#    clear directions next to the object code saying where to find the
#    Corresponding Source.  Regardless of what server hosts the
#    Corresponding Source, you remain obligated to ensure that it is
#    available for as long as needed to satisfy these requirements.
#
#    e) Convey the object code using peer-to-peer transmission, provided
#    you inform other peers where the object code and Corresponding
#    Source of the work are being offered to the general public at no
#    charge under subsection 6d.
#
#  A separable portion of the object code, whose source code is excluded
#from the Corresponding Source as a System Library, need not be
#included in conveying the object code work.
#
#  A "User Product" is either (1) a "consumer product", which means any
#tangible personal property which is normally used for personal, family,
#or household purposes, or (2) anything designed or sold for incorporation
#into a dwelling.  In determining whether a product is a consumer product,
#doubtful cases shall be resolved in favor of coverage.  For a particular
#product received by a particular user, "normally used" refers to a
#typical or common use of that class of product, regardless of the status
#of the particular user or of the way in which the particular user
#actually uses, or expects or is expected to use, the product.  A product
#is a consumer product regardless of whether the product has substantial
#commercial, industrial or non-consumer uses, unless such uses represent
#the only significant mode of use of the product.
#
#  "Installation Information" for a User Product means any methods,
#procedures, authorization keys, or other information required to install
#and execute modified versions of a covered work in that User Product from
#a modified version of its Corresponding Source.  The information must
#suffice to ensure that the continued functioning of the modified object
#code is in no case prevented or interfered with solely because
#modification has been made.
#
#  If you convey an object code work under this section in, or with, or
#specifically for use in, a User Product, and the conveying occurs as
#part of a transaction in which the right of possession and use of the
#User Product is transferred to the recipient in perpetuity or for a
#fixed term (regardless of how the transaction is characterized), the
#Corresponding Source conveyed under this section must be accompanied
#by the Installation Information.  But this requirement does not apply
#if neither you nor any third party retains the ability to install
#modified object code on the User Product (for example, the work has
#been installed in ROM).
#
#  The requirement to provide Installation Information does not include a
#requirement to continue to provide support service, warranty, or updates
#for a work that has been modified or installed by the recipient, or for
#the User Product in which it has been modified or installed.  Access to a
#network may be denied when the modification itself materially and
#adversely affects the operation of the network or violates the rules and
#protocols for communication across the network.
#
#  Corresponding Source conveyed, and Installation Information provided,
#in accord with this section must be in a format that is publicly
#documented (and with an implementation available to the public in
#source code form), and must require no special password or key for
#unpacking, reading or copying.
#
#  7. Additional Terms.
#
#  "Additional permissions" are terms that supplement the terms of this
#License by making exceptions from one or more of its conditions.
#Additional permissions that are applicable to the entire Program shall
#be treated as though they were included in this License, to the extent
#that they are valid under applicable law.  If additional permissions
#apply only to part of the Program, that part may be used separately
#under those permissions, but the entire Program remains governed by
#this License without regard to the additional permissions.
#
#  When you convey a copy of a covered work, you may at your option
#remove any additional permissions from that copy, or from any part of
#it.  (Additional permissions may be written to require their own
#removal in certain cases when you modify the work.)  You may place
#additional permissions on material, added by you to a covered work,
#for which you have or can give appropriate copyright permission.
#
#  Notwithstanding any other provision of this License, for material you
#add to a covered work, you may (if authorized by the copyright holders of
#that material) supplement the terms of this License with terms:
#
#    a) Disclaiming warranty or limiting liability differently from the
#    terms of sections 15 and 16 of this License; or
#
#    b) Requiring preservation of specified reasonable legal notices or
#    author attributions in that material or in the Appropriate Legal
#    Notices displayed by works containing it; or
#
#    c) Prohibiting misrepresentation of the origin of that material, or
#    requiring that modified versions of such material be marked in
#    reasonable ways as different from the original version; or
#
#    d) Limiting the use for publicity purposes of names of licensors or
#    authors of the material; or
#
#    e) Declining to grant rights under trademark law for use of some
#    trade names, trademarks, or service marks; or
#
#    f) Requiring indemnification of licensors and authors of that
#    material by anyone who conveys the material (or modified versions of
#    it) with contractual assumptions of liability to the recipient, for
#    any liability that these contractual assumptions directly impose on
#    those licensors and authors.
#
#  All other non-permissive additional terms are considered "further
#restrictions" within the meaning of section 10.  If the Program as you
#received it, or any part of it, contains a notice stating that it is
#governed by this License along with a term that is a further
#restriction, you may remove that term.  If a license document contains
#a further restriction but permits relicensing or conveying under this
#License, you may add to a covered work material governed by the terms
#of that license document, provided that the further restriction does
#not survive such relicensing or conveying.
#
#  If you add terms to a covered work in accord with this section, you
#must place, in the relevant source files, a statement of the
#additional terms that apply to those files, or a notice indicating
#where to find the applicable terms.
#
#  Additional terms, permissive or non-permissive, may be stated in the
#form of a separately written license, or stated as exceptions;
#the above requirements apply either way.
#
#  8. Termination.
#
#  You may not propagate or modify a covered work except as expressly
#provided under this License.  Any attempt otherwise to propagate or
#modify it is void, and will automatically terminate your rights under
#this License (including any patent licenses granted under the third
#paragraph of section 11).
#
#  However, if you cease all violation of this License, then your
#license from a particular copyright holder is reinstated (a)
#provisionally, unless and until the copyright holder explicitly and
#finally terminates your license, and (b) permanently, if the copyright
#holder fails to notify you of the violation by some reasonable means
#prior to 60 days after the cessation.
#
#  Moreover, your license from a particular copyright holder is
#reinstated permanently if the copyright holder notifies you of the
#violation by some reasonable means, this is the first time you have
#received notice of violation of this License (for any work) from that
#copyright holder, and you cure the violation prior to 30 days after
#your receipt of the notice.
#
#  Termination of your rights under this section does not terminate the
#licenses of parties who have received copies or rights from you under
#this License.  If your rights have been terminated and not permanently
#reinstated, you do not qualify to receive new licenses for the same
#material under section 10.
#
#  9. Acceptance Not Required for Having Copies.
#
#  You are not required to accept this License in order to receive or
#run a copy of the Program.  Ancillary propagation of a covered work
#occurring solely as a consequence of using peer-to-peer transmission
#to receive a copy likewise does not require acceptance.  However,
#nothing other than this License grants you permission to propagate or
#modify any covered work.  These actions infringe copyright if you do
#not accept this License.  Therefore, by modifying or propagating a
#covered work, you indicate your acceptance of this License to do so.
#
#  10. Automatic Licensing of Downstream Recipients.
#
#  Each time you convey a covered work, the recipient automatically
#receives a license from the original licensors, to run, modify and
#propagate that work, subject to this License.  You are not responsible
#for enforcing compliance by third parties with this License.
#
#  An "entity transaction" is a transaction transferring control of an
#organization, or substantially all assets of one, or subdividing an
#organization, or merging organizations.  If propagation of a covered
#work results from an entity transaction, each party to that
#transaction who receives a copy of the work also receives whatever
#licenses to the work the party's predecessor in interest had or could
#give under the previous paragraph, plus a right to possession of the
#Corresponding Source of the work from the predecessor in interest, if
#the predecessor has it or can get it with reasonable efforts.
#
#  You may not impose any further restrictions on the exercise of the
#rights granted or affirmed under this License.  For example, you may
#not impose a license fee, royalty, or other charge for exercise of
#rights granted under this License, and you may not initiate litigation
#(including a cross-claim or counterclaim in a lawsuit) alleging that
#any patent claim is infringed by making, using, selling, offering for
#sale, or importing the Program or any portion of it.
#
#  11. Patents.
#
#  A "contributor" is a copyright holder who authorizes use under this
#License of the Program or a work on which the Program is based.  The
#work thus licensed is called the contributor's "contributor version".
#
#  A contributor's "essential patent claims" are all patent claims
#owned or controlled by the contributor, whether already acquired or
#hereafter acquired, that would be infringed by some manner, permitted
#by this License, of making, using, or selling its contributor version,
#but do not include claims that would be infringed only as a
#consequence of further modification of the contributor version.  For
#purposes of this definition, "control" includes the right to grant
#patent sublicenses in a manner consistent with the requirements of
#this License.
#
#  Each contributor grants you a non-exclusive, worldwide, royalty-free
#patent license under the contributor's essential patent claims, to
#make, use, sell, offer for sale, import and otherwise run, modify and
#propagate the contents of its contributor version.
#
#  In the following three paragraphs, a "patent license" is any express
#agreement or commitment, however denominated, not to enforce a patent
#(such as an express permission to practice a patent or covenant not to
#sue for patent infringement).  To "grant" such a patent license to a
#party means to make such an agreement or commitment not to enforce a
#patent against the party.
#
#  If you convey a covered work, knowingly relying on a patent license,
#and the Corresponding Source of the work is not available for anyone
#to copy, free of charge and under the terms of this License, through a
#publicly available network server or other readily accessible means,
#then you must either (1) cause the Corresponding Source to be so
#available, or (2) arrange to deprive yourself of the benefit of the
#patent license for this particular work, or (3) arrange, in a manner
#consistent with the requirements of this License, to extend the patent
#license to downstream recipients.  "Knowingly relying" means you have
#actual knowledge that, but for the patent license, your conveying the
#covered work in a country, or your recipient's use of the covered work
#in a country, would infringe one or more identifiable patents in that
#country that you have reason to believe are valid.
#
#  If, pursuant to or in connection with a single transaction or
#arrangement, you convey, or propagate by procuring conveyance of, a
#covered work, and grant a patent license to some of the parties
#receiving the covered work authorizing them to use, propagate, modify
#or convey a specific copy of the covered work, then the patent license
#you grant is automatically extended to all recipients of the covered
#work and works based on it.
#
#  A patent license is "discriminatory" if it does not include within
#the scope of its coverage, prohibits the exercise of, or is
#conditioned on the non-exercise of one or more of the rights that are
#specifically granted under this License.  You may not convey a covered
#work if you are a party to an arrangement with a third party that is
#in the business of distributing software, under which you make payment
#to the third party based on the extent of your activity of conveying
#the work, and under which the third party grants, to any of the
#parties who would receive the covered work from you, a discriminatory
#patent license (a) in connection with copies of the covered work
#conveyed by you (or copies made from those copies), or (b) primarily
#for and in connection with specific products or compilations that
#contain the covered work, unless you entered into that arrangement,
#or that patent license was granted, prior to 28 March 2007.
#
#  Nothing in this License shall be construed as excluding or limiting
#any implied license or other defenses to infringement that may
#otherwise be available to you under applicable patent law.
#
#  12. No Surrender of Others' Freedom.
#
#  If conditions are imposed on you (whether by court order, agreement or
#otherwise) that contradict the conditions of this License, they do not
#excuse you from the conditions of this License.  If you cannot convey a
#covered work so as to satisfy simultaneously your obligations under this
#License and any other pertinent obligations, then as a consequence you may
#not convey it at all.  For example, if you agree to terms that obligate you
#to collect a royalty for further conveying from those to whom you convey
#the Program, the only way you could satisfy both those terms and this
#License would be to refrain entirely from conveying the Program.
#
#  13. Use with the GNU Affero General Public License.
#
#  Notwithstanding any other provision of this License, you have
#permission to link or combine any covered work with a work licensed
#under version 3 of the GNU Affero General Public License into a single
#combined work, and to convey the resulting work.  The terms of this
#License will continue to apply to the part which is the covered work,
#but the special requirements of the GNU Affero General Public License,
#section 13, concerning interaction through a network will apply to the
#combination as such.
#
#  14. Revised Versions of this License.
#
#  The Free Software Foundation may publish revised and/or new versions of
#the GNU General Public License from time to time.  Such new versions will
#be similar in spirit to the present version, but may differ in detail to
#address new problems or concerns.
#
#  Each version is given a distinguishing version number.  If the
#Program specifies that a certain numbered version of the GNU General
#Public License "or any later version" applies to it, you have the
#option of following the terms and conditions either of that numbered
#version or of any later version published by the Free Software
#Foundation.  If the Program does not specify a version number of the
#GNU General Public License, you may choose any version ever published
#by the Free Software Foundation.
#
#  If the Program specifies that a proxy can decide which future
#versions of the GNU General Public License can be used, that proxy's
#public statement of acceptance of a version permanently authorizes you
#to choose that version for the Program.
#
#  Later license versions may give you additional or different
#permissions.  However, no additional obligations are imposed on any
#author or copyright holder as a result of your choosing to follow a
#later version.
#
#  15. Disclaimer of Warranty.
#
#  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
#APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
#HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
#OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
#THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
#IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
#ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
#
#  16. Limitation of Liability.
#
#  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
#WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
#THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
#GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
#USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
#DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
#PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
#EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
#SUCH DAMAGES.
#
#  17. Interpretation of Sections 15 and 16.
#
#  If the disclaimer of warranty and limitation of liability provided
#above cannot be given local legal effect according to their terms,
#reviewing courts shall apply local law that most closely approximates
#an absolute waiver of all civil liability in connection with the
#Program, unless a warranty or assumption of liability accompanies a
#copy of the Program in return for a fee.
#
#                     END OF TERMS AND CONDITIONS
#
#            How to Apply These Terms to Your New Programs
#
#  If you develop a new program, and you want it to be of the greatest
#possible use to the public, the best way to achieve this is to make it
#free software which everyone can redistribute and change under these terms.
#
#  To do so, attach the following notices to the program.  It is safest
#to attach them to the start of each source file to most effectively
#state the exclusion of warranty; and each file should have at least
#the "copyright" line and a pointer to where the full notice is found.
#
#    <one line to give the program's name and a brief idea of what it does.>
#    Copyright (C) <year>  <name of author>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Also add information on how to contact you by electronic and paper mail.
#
#  If the program does terminal interaction, make it output a short
#notice like this when it starts in an interactive mode:
#
#    <program>  Copyright (C) <year>  <name of author>
#    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
#    This is free software, and you are welcome to redistribute it
#    under certain conditions; type `show c' for details.
#
#The hypothetical commands `show w' and `show c' should show the appropriate
#parts of the General Public License.  Of course, your program's commands
#might be different; for a GUI interface, you would use an "about box".
#
#  You should also get your employer (if you work as a programmer) or school,
#if any, to sign a "copyright disclaimer" for the program, if necessary.
#For more information on this, and how to apply and follow the GNU GPL, see
#<http://www.gnu.org/licenses/>.
#
#  The GNU General Public License does not permit incorporating your program
#into proprietary programs.  If your program is a subroutine library, you
#may consider it more useful to permit linking proprietary applications with
#the library.  If this is what you want to do, use the GNU Lesser General
#Public License instead of this License.  But first, please read
#<http://www.gnu.org/philosophy/why-not-lgpl.html>.

#These variables (in main) are used by printVersion()
my $template_version_number = '1.33';
my $software_version_number = '1.6';

##
## Start Main
##

use strict;
use Getopt::Long;

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix);#,$paralogs_suffix); #Not defined so a user can overwrite
                                         #the input file
my @input_files             = ();
my $current_output_file     = '';
my $help                    = 0;
my $version                 = 0;
my $force                   = 0;
my $evalue_cutoff           = 10**-30;
my $length_ratio_cutoff     = .9;
my $percent_identity_cutoff = 10;
my $use_reference           = 0;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, printVersion, getCommand and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;

my $GetOptHash =
  {'e|evalue-cutoff=s'  => \$evalue_cutoff,          #OPTIONAL [10^-30]
   'l|length-ratio-cutoff=s' => \$length_ratio_cutoff,      #OPTIONAL [0.9]
   'p|percent-identity-cutoff=s' => \$percent_identity_cutoff, #OPTIONAL [10]
   'i|input-file=s'     => sub {push(@input_files,   #REQUIRED unless <> is
				     sglob($_[1]))}, #         supplied
   '<>'                 => sub {push(@input_files,   #REQUIRED unless -i is
				     sglob($_[0]))}, #         supplied
   'b|fully-bidirectional!' => \$use_reference,      #OPTIONAL [Off]
#   'u|uniques-suffix=s' => \$paralogs_suffix,        #OPTIONAL [undef]
   'o|outfile-suffix=s' => \$outfile_suffix,         #OPTIONAL [undef]
   'f|force!'           => \$force,                  #OPTIONAL [Off]
   'v|verbose!'         => \$verbose,                #OPTIONAL [Off]
   'q|quiet!'           => \$quiet,                  #OPTIONAL [Off]
   'h|help!'            => \$help,                   #OPTIONAL [Off]
   'debug!'             => \$DEBUG,                  #OPTIONAL [Off]
   'version!'           => \$version,                #OPTIONAL [Off]
  };

#If there are no arguments and no files directed or piped in
if(scalar(@ARGV) == 0 && isStandardInputFromTerminal())
  {
    usage();
    exit(0);
  }

#Get the input options
GetOptions(%$GetOptHash);

#Print the debug mode (it checks the value of the DEBUG global variable)
debug("Debug mode on.");

#If the user has asked for help, call the help subroutine
if($help)
  {
    help();
    exit(0);
  }

#If the user has asked for the software version, print it
if($version)
  {
    printVersion();
    exit(0);
  }

#Check validity of verbosity options
if($verbose && $quiet)
  {
    $quiet = 0;
    error("You cannot supply verbose and quiet flags at the same time.");
    exit(1);
  }

#Put standard input into the input_files array if standard input has been redirected in
if(!isStandardInputFromTerminal())
  {
    push(@input_files,'-');

    #Warn the user about the naming of the outfile when using STDIN
    if(defined($outfile_suffix))
      {warning("Input on STDIN detected along with an outfile suffix.  Your ",
	       "output file will be named STDIN$outfile_suffix")}
  }

#Make sure there is input
if(scalar(@input_files) == 0)
  {
    error("No input files detected.");
    usage(1);
    exit(2);
  }

#Check to make sure previously generated output files won't be over-written
if(!$force && defined($outfile_suffix))
  {
    my $existing_outfiles = [];
    foreach my $output_file (map {($_ eq '-' ? 'STDIN' : $_) . $outfile_suffix}
			     @input_files)
      {push(@$existing_outfiles,$output_file) if(-e $output_file)}

    if(scalar(@$existing_outfiles))
      {
	error("The output files: [@$existing_outfiles] already exist.  ",
	      "Use -f to force overwrite.  E.g.\n\t",
	      getCommand(1),' --force');
	exit(3);
      }
  }

if(isStandardOutputToTerminal() && !defined($outfile_suffix))
  {verbose("NOTE: VerboseOverMe functionality has been altered to yield clean STDOUT ",
	   "output.")}

$use_reference = !$use_reference;

verbose("Run conditions: ",getCommand(1),"\n");

#If output is going to STDOUT instead of output files with different extensions
if(!defined($outfile_suffix))
  {verbose("[STDOUT] Opened for all output.")}

my $genomes_done_hash = {};

#For each input file
foreach my $input_file (@input_files)
  {
    my $hit_hash = {};

    my $parent_dir = $input_file;
    $parent_dir =~ s/[^\/]+$//;

    #If an output file name suffix has been defined
    if(defined($outfile_suffix))
      {
	##
	## Open and select the next output file
	##

	#Set the current output file name
	$current_output_file = ($input_file eq '-' ? 'STDIN' : $input_file)
	  . $outfile_suffix;

	#Open the output file
	if(!open(OUTPUT,">$current_output_file"))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open output file: [$current_output_file]\n$!");
	    next;
	  }
	else
	  {verboseOverMe("[$current_output_file] Opened output file.")}

	#Select the output file handle
	select(OUTPUT);
      }

    #Open the input file
    if(!open(INPUT,$input_file))
      {
	#Report an error and iterate if there was an error
	error("Unable to open input file: [$input_file]\n$!");
	next;
      }
    else
      {verboseOverMe("[",
		     ($input_file eq '-' ? 'STDIN' : $input_file),
		     "] Opened input file.")}

    my $line_num             = 0;
    my $num_length_warnings  = 0;
    my $num_sim_warnings     = 0;
    my $fragment_check       = {};
    my $indirect_recip_check = {};
    my $query_check_hash     = {};
    my $query_double_check   = {};
    my $file_check_hash      = {};

    #For each line in the current input file
    while(getLine(*INPUT))
      {
	$line_num++;
	verboseOverMe("[",
		      ($input_file eq '-' ? 'STDIN' : $input_file),
		      "] Reading line: [$line_num].");

	my($query_file,$subject_file,$query_id,$subject_id,$match_length_ratio,
	   $evalue,$percent_identity,$link_id);
	($query_file,$subject_file,$query_id,$subject_id,$match_length_ratio,
	 $evalue,$percent_identity,$link_id) = split(/ *\t */,$_);
	$link_id = '' unless(defined($link_id));

	unless(exists($query_check_hash->{$query_id}))
	  {
	    $query_check_hash->{$query_id}   = 0;
	    $query_double_check->{$query_id} = 0;
	  }

	$file_check_hash->{$query_file}++;
	$file_check_hash->{$subject_file}++;

	#If the match length ratio was given as a percent instead of fractional
	#value, convert it to a fraction.  This could fail if 2% was ever
	#expected as a valid percent match length, but that's very unlikely to
	#ever be desireable
	if($match_length_ratio > 2)
	  {
	    $match_length_ratio /= 100;
	    $num_length_warnings++;
	  }

	#If the percent similarity was given as a fractional value instead of a
        #percent, convert it to a percent.  This could fail if 2% was ever
	#expected as a valid percent match length, but that's very unlikely to
	#ever be desireable
	if($percent_identity < 2)
	  {
	    $percent_identity *= 100;
	    $num_sim_warnings++;
	  }

	$evalue = '1' . $evalue if($evalue =~ /^e/i);

	if(#This hit meets all the cutoffs AND
	   $match_length_ratio >= $length_ratio_cutoff     &&
	   $evalue             <= $evalue_cutoff           &&
	   $percent_identity   >= $percent_identity_cutoff &&

	   #This hit pair does not yet exist OR
	   (!exists($hit_hash->{$query_file}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}
		    ->{$subject_id}) ||

	    #This hit pair does exist AND
	    (exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}
		    ->{$subject_id}) &&

	     #It's a more-authentic hit OR
	     (($hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{LINKID} ne '' && $link_id eq '') ||

	      #It's an authentic hit that is simply all-around better
	      ($link_id eq '' &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{LENGTHRATIO} <= $match_length_ratio &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{EVALUE} >= $evalue &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{IDENTITY} <= $percent_identity)))))
	   {
	     $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id} =
		 {LENGTHRATIO => $match_length_ratio,
		  EVALUE      => $evalue,
		  IDENTITY    => $percent_identity,
		  LINKID      => $link_id};

	     $query_check_hash->{$query_id}++;
	   }
	else
	  {
	    debug("Passing up hit: [$query_file, $subject_file, $query_id, ",
		  "$subject_id, $match_length_ratio, $evalue, ",
		  "$percent_identity].")
	      if($query_check_hash->{$query_id} == 0);
	    $query_double_check->{$query_id}++;
	  }

	#If this is an indirect link between two fragments (This assumes
	#there's no more than 2 lines with the same combination of files and
	#IDs)
	if($link_id ne '')
	  {
	    #If the reciprocal has already been recorded
	    if(exists($indirect_recip_check->{$subject_file}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}
		      ->{$subject_id}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}
		      ->{$subject_id}->{$query_id}))
	      {
		#Delete it
		delete($indirect_recip_check->{$subject_file}->{$query_file}
		       ->{$subject_id}->{$query_id});
		if(scalar(keys(%{$indirect_recip_check->{$subject_file}
				   ->{$query_file}->{$subject_id}})) == 0)
		  {
		    delete($indirect_recip_check->{$subject_file}
			   ->{$query_file}->{$subject_id});
		    if(scalar(keys(%{$indirect_recip_check->{$subject_file}
				       ->{$query_file}})) == 0)
		      {
			delete($indirect_recip_check->{$subject_file}
			       ->{$query_file});
			if(scalar(keys(%{$indirect_recip_check
					   ->{$subject_file}})) == 0)
			  {delete($indirect_recip_check->{$subject_file})}
		      }
		  }
	      }
	    else #Record it
	      {$indirect_recip_check->{$query_file}->{$subject_file}
		 ->{$query_id}->{$subject_id} = 0}
	  }

	#Check to see if this is a direct hit between two fragments that meets
	#the length match ratio cutoff but not one or both of the others
	if($match_length_ratio >= $length_ratio_cutoff    &&
	   ($evalue > $evalue_cutoff ||
	    $percent_identity < $percent_identity_cutoff) &&
	   $link_id eq '')
	  {
	    #Keep this hit for later to check to see if it should trump an
	    #indirect hit between the same two fragments
	    $fragment_check->{$query_file}->{$subject_file}->{$query_id}
	      ->{$subject_id} =
		{LENGTHRATIO => $match_length_ratio,
		 EVALUE      => $evalue,
		 IDENTITY    => $percent_identity,
		 LINKID      => $link_id};
	  }
      }

    if($num_length_warnings)
      {warning("It appears as though [$input_file] has $num_length_warnings ",
	       'lines that have the match length ratio in percentage format ',
	       'instead of in the expected fractional format.  This could be ',
	       'due to indirect hit additions via a cluster database to ',
	       'mitigate fragmentary starting data.  The data has ',
	       'been converted.')}
    if($num_sim_warnings)
      {warning("It appears as though [$input_file] has $num_sim_warnings ",
	       'lines that have the percent similarity in fractional format ',
	       'instead of in the expected percentage format.  The data has ',
	       'been converted.')}

    #Check to see that indirect hits were entered correctly (i.e. that
    #bidirectional hits were entered)
    if(keys(%$indirect_recip_check))
      {
	my $err_string = '';
	foreach my $query_file (keys(%$indirect_recip_check))
	  {foreach my $subject_file (keys(%{$indirect_recip_check
					      ->{$query_file}}))
	     {foreach my $query_id (keys(%{$indirect_recip_check
					     ->{$query_file}
					       ->{$subject_file}}))
		{foreach my $subject_id (keys(%{$indirect_recip_check
						  ->{$query_file}
						    ->{$subject_file}
						      ->{$query_id}}))
		   {$err_string .= $indirect_recip_check->{$query_file}
		      ->{$subject_file}->{$query_id}->{$subject_id}->{LINKID} .
			','}}}}
	$err_string =~ s/,$//;
	error('It appears that 1 or more indirect hits to a reference set of ',
	      "sequences was not entered into the input file: [$input_file] ",
	      'in a bidirecdtional manner.  Either this script should be ',
	      'updated to add the reciprocal hit automatically or you need ',
	      'to include the reciprocal entries in your input file.  Here ',
	      'are the indirect link IDs (from the last column of the input ',
	      "data) without reciprocal hits: [$err_string].");
	undef($indirect_recip_check);
      }

    #If this file pair is for finding paralogs
    if(scalar(keys(%$file_check_hash)) == 1)
      {
	#Make sure every query has a good hit
	my @missing_query_ids = grep {$query_check_hash->{$_} == 0}
	  keys(%$query_check_hash);
	my @passed_up = grep {exists($query_double_check->{$_})}
	  @missing_query_ids;
	if(scalar(@missing_query_ids))
	  {
	    warning("These [",scalar(@missing_query_ids),"] queries out of [",
		    scalar(keys(%$query_check_hash)),"], [",scalar(@passed_up),
		    "] of which had hits but all of them (including hits to ",
		    "self) failed the filtering criteria: [",
		    (join(',',(scalar(@missing_query_ids) > 5 && !$DEBUG ?
			       (@missing_query_ids[0..4],'...') :
			       @missing_query_ids))),
		    "].  To reclaim these sequences, you must rerun and ",
		    "either loosen the filtering parameters, or rerun blast ",
		    "and increase its -v/-b parameters.  Also, check the ",
		    "validity of the blast result files to make sure they ",
		    "are complete.");
	  }
      }

    close(INPUT);

    verbose("[",
	    ($input_file eq '-' ? 'STDIN' : $input_file),
	    '] Input file done.  Time taken: [',
	    scalar(markTime()),
	    " Seconds].");

    if(scalar(keys(%$hit_hash)) == 0)
      {
	error("No hits were parsed from input file: [$input_file].  ",
	      "Skipping.");
	next;
      }

    #If there were indirect hits in the file
    #Go through the hit_hash

    #Go through the fragment_check hash to see if it should trump any indirect
    #hits.  We are assuming here that the hits in this hash are bad for one
    #reason or another, but that they meet the length match ratio requirement
    foreach my $query_file (keys(%$fragment_check))
      {
	next unless(exists($hit_hash->{$query_file}));
	foreach my $subject_file (keys(%{$fragment_check->{$query_file}}))
	  {
	    next unless(exists($hit_hash->{$query_file}->{$subject_file}));
	    foreach my $query_id (keys(%{$fragment_check->{$query_file}
					   ->{$subject_file}}))
	      {
		next unless(exists($hit_hash->{$query_file}->{$subject_file}
				   ->{$query_id}));
		foreach my $subject_id (keys(%{$fragment_check->{$query_file}
						 ->{$subject_file}
						   ->{$query_id}}))
		  {
		    next unless(exists($hit_hash->{$query_file}
				       ->{$subject_file}->{$query_id}
				       ->{$subject_id}));

		    #If the recorded hit is an indirect one that hits a
		    #reference sequence link
		    if($fragment_check->{$query_file}->{$subject_file}
		       ->{$query_id}->{$subject_id}->{LINKID} ne '')
		      {
			#Remove it from the hit hash
			delete($hit_hash->{$query_file}->{$subject_file}
				       ->{$query_id}->{$subject_id});
			if(scalar(keys(%{$hit_hash->{$query_file}
					   ->{$subject_file}->{$query_id}})) ==
			   0)
			  {
			    delete($hit_hash->{$query_file}->{$subject_file}
				   ->{$query_id});
			    if(scalar(keys(%{$hit_hash->{$query_file}
					       ->{$subject_file}})) == 0)
			      {
				delete($hit_hash->{$query_file}
				       ->{$subject_file});
				if(scalar(keys(%{$hit_hash->{$query_file}})) ==
				   0)
				  {delete($hit_hash->{$query_file})}
			      }
			  }
		      }
		  }
	      }
	  }
      }

    undef($fragment_check);

#    #If an output file name suffix is set
#    if(defined($outfile_suffix))
#      {
#	#Select standard out
#	select(STDOUT);
#	#Close the output file handle
#	close(OUTPUT);
#
#	verbose("[$current_output_file] Output file done.");
#      }
#  }

    my $seed_query_genome   = (keys(%$hit_hash))[0];
    my $seed_subject_genome = (keys(%{$hit_hash->{$seed_query_genome}}))[0];
    my @seed_gene_set =
      sort
	{
	  #Sort by ascending number of hits (to avoid low-quality hits causing
	  #unique genes to get added to other groups), descending length,
	  #descending sim, and ascending eval) so that we
	  #can greedily select paralogous groups that are composed of unique
	  #members.  If we did not do this, we might end up with duplicate IDs
	  #in the group output (this sorting is actually part of a bug-fix for
	  #that)
#	  my $num_hits_a    = 0;
#	  my $num_hits_b    = 0;
	  my $max_len_rat_a = 0;
	  my $max_len_rat_b = 0;
	  my $max_pct_sim_a = 0;
	  my $max_pct_sim_b = 0;
	  my($min_eval_a,$min_eval_b);
	  foreach my $subida (keys(%{$hit_hash->{$seed_query_genome}
				       ->{$seed_subject_genome}->{$a}}))
	    {
#	      $num_hits_a++;
	      $max_len_rat_a =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$a}
		  ->{$subida}->{LENGTHRATIO}
		    if($hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$a}->{$subida}->{LENGTHRATIO} > $max_len_rat_a);
	      $max_pct_sim_a =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$a}
		  ->{$subida}->{IDENTITY}
		    if($hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$a}->{$subida}->{IDENTITY} > $max_pct_sim_a);
	      $min_eval_a =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$a}
		  ->{$subida}->{EVALUE}
		    if(!defined($min_eval_a) ||
		       $hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$a}->{$subida}->{EVALUE} < $max_pct_sim_a);
	    }
	  foreach my $subidb (keys(%{$hit_hash->{$seed_query_genome}
				       ->{$seed_subject_genome}->{$b}}))
	    {
#	      $num_hits_b++;
	      $max_len_rat_b =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$b}
		  ->{$subidb}->{LENGTHRATIO}
		    if($hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$b}->{$subidb}->{LENGTHRATIO} > $max_len_rat_b);
	      $max_pct_sim_b =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$b}
		  ->{$subidb}->{IDENTITY}
		    if($hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$b}->{$subidb}->{IDENTITY} > $max_pct_sim_b);
	      $min_eval_b =
		$hit_hash->{$seed_query_genome}->{$seed_subject_genome}->{$b}
		  ->{$subidb}->{EVALUE}
		    if(!defined($min_eval_b) ||
		       $hit_hash->{$seed_query_genome}->{$seed_subject_genome}
		       ->{$b}->{$subidb}->{EVALUE} < $max_pct_sim_b);
	    }
#	  $num_hits_a <=> $num_hits_b ||
	    $max_len_rat_b <=> $max_len_rat_a ||
	      $max_pct_sim_b <=> $max_pct_sim_a ||
		$min_eval_a <=> $min_eval_b
	}
      keys(%{$hit_hash->{$seed_query_genome}->{$seed_subject_genome}});
    my $num_genomes = scalar(keys(%$hit_hash));

    #Keep an array of groups which should each contain n arrays - one for each
    #genome.  In each genome's array will be the genome's file name followed by
    #all the genes in the group.  Here's an example:
    # [[[genome1,gene1],[genome2,gene1]...]...].  This array contains 1 group.
    #Two genomes are depicted and they each have 1 gene in the group
    my $common_groups = [];

    my $seen_hash = {};

    #A reference is arbitrarily chosen as the seed genome.  It's paralogs are
    #gathered first and then all their hits are gathered to be bidirectional
    #hits with the seed, then the non-seed group of genes are checked loosely
    #to see if they, as a group, have one member that hits a gene from another
    #gene in the other non-seed groups
    if($use_reference)
      {
	verbose("Building candidate set of common genes...");

	##
	##I just wrote the following code (which I have not tested) and some code above but I have decided to not implement it because: If I start artificially removing genes from groups that have the requisite hits to be in, I would be trying to mitigate poor quality blasting (e.g. short sequences or high e-value cut-off) in this script, which I don't think is a good idea.  A better idea is for the blasting to be done better.  This issue can be mitigated by making the filtering/clustering cutoffs more stringent.  So I'm going to comment out the code below and leave the error above about duplicates.  I'm also going to leave the sort I did above to greedily select paralogous sets.
	##

#    #Create the sets of paralogs we're going to use.  We're doing this first to
#    #be able to select the paralogous set a seed gene belongs to (by it's best
#    #hit) if it ends up being put in multiuple groups.
#    my @seed_paralogous_sets = ();
#    foreach my $seed_query_gene (@seed_gene_set)
#      {
#	verboseOverMe("Trying seed gene: [$seed_query_gene].");
#
#	next if(exists($seen_hash->{$seed_query_gene}));
#
#	#Try to build a set
#	my @paralogs = (grep {exists($hit_hash->{$seed_query_genome} #bidirect.
#				     ->{$seed_query_genome}->{$_}    #check
#				     ->{$seed_query_gene})}
#			keys(%{$hit_hash->{$seed_query_genome}
#				 ->{$seed_query_genome}->{$seed_query_gene}}));
#
#	my $index = scalar(@seed_paralogous_sets);
#	push(@seed_paralogous_sets,[@paralogs]);
#
#	#Update the seen hash so we can skip them later
#	foreach my $paralog (@paralogs)
#	  {
#	    if(exists($seen_hash->{$paralog}) &&
#	       exists($seen_hash->{$paralog}->{$seed_query_gene}) &&
#	       $seen_hash->{$paralog}->{$seed_query_gene}->{SCORE}
#	       ->{LENGTHRATIO} >
#	       $hit_hash->{$seed_query_genome}->{$seed_query_genome}
#	       ->{$seed_query_gene}->{$paralog}->{LENGTHRATIO})
#	      {
#		warning("Multiple hits above the cutoff between the same two ",
#			"genes.  Since the previous script in this pipeline ",
#			"was supposed to merge these instances, you may want ",
#			"to make your cutoffs more stringent or else allow ",
#			"merging errors in the previous script.  Keeping the ",
#			"best hit.  This could potentially cause us to miss ",
#			"some bidirectional groups.")
#		next;
#	      }
#	    #Record the location of the paralogous set this was put into
#	    $seen_hash->{$paralog}->{$seed_query_gene}->{INDEX} = $index;
#	    #Record the score hash of the hit that caused this to be added
#	    $seen_hash->{$paralog}->{$seed_query_gene}->{SCORE} =
#	      $hit_hash->{$seed_query_genome}->{$seed_query_genome}
#		->{$seed_query_gene}->{$paralog};
#	  }
#      }
#
#    my $num_problems = scalar(grep {scalar(keys(%$_)) > 1} keys(%$seen_hash));
#    if($num_problems)
#      {
#	error("Given the cutoffs you supplied, there appear to be [$num_problems] genes in the seed set that can belong to multiple paralogous sets because some genes which do not bidirectionally hit eachother, bidirectionally hit the same gene(s).  This suggests that you should make your hit cutoffs more stringent or that your blast results contain short hits (which cannot be filtered by this script - they must be filtered in previous steps).  This script will keep the best of such hits and remove duplicates from the other sets, but be mindful of the problem when interpretting the results.  Note that this problem is mitigated by the fact that the \%length match generated by the previous script in this pipeline calculates percentage by the shortest whole sequence length, not match length, and this work-around selects the largest \%length match to decide which paralogous set a get belongs to.");
#      }
#
#    #Now if a gene was added to multiple paralogous sets, keep the one it hit
#    #best and remove the rest
#    foreach my $dupe_paralog (grep {scalar(keys(%$_)) > 1} keys(%$seen_hash))
#      {
#	#Determine the best scoring occurrence of this paralog in sets of
#	#paralogs (except for a hit to self)
#	my $best_one =
#	  (sort {$seen_hash->{$dupe_paralog}->{$b}->{SCORE}->{LENGTHRATIO} <=>
#		   $seen_hash->{$dupe_paralog}->{$a}->{SCORE}->{LENGTHRATIO} ||
#		     $seen_hash->{$dupe_paralog}->{$b}->{SCORE}->{IDENTITY} <=>
#		       $seen_hash->{$dupe_paralog}->{$a}->{SCORE}
#			 ->{IDENTITY} ||
#			   $seen_hash->{$dupe_paralog}->{$a}->{SCORE}
#			     ->{EVALUE} <=>
#			       $seen_hash->{$dupe_paralog}->{$b}->{SCORE}
#				 ->{EVALUE}}
#	   grep {$_ ne $dupe_paralog}
#	   keys(%{$seen_hash->{$dupe_paralog}}))[0];
#
#	#Now remove this paralog from all sets of paralogs except the best one
#	foreach my $seed_paralog_query (keys(%{$seen_hash->{$dupe_paralog}}))
#	  {
#	    next if($seed_paralog_query eq $best_one);
#	    my $index = $seen_hash->{$dupe_paralog}->{$seed_paralog_query}
#	      ->{INDEX};
#	    $seed_paralogous_sets[$index] =
#	      [grep {$_ ne $dupe_paralog} @{$seed_paralogous_sets[$index]}];
#	  }
#      }
#
#    #Now filter the paralogous sets for just those that actually contain
#    #members
#    @seed_paralogous_sets = grep {scalar(@$_)} @seed_paralogous_sets;
#
#    foreach my $tmp_paralogs (@seed_paralogous_sets)
#      {
#	my @paralogs = @$tmp_paralogs;

	foreach my $seed_query_gene (@seed_gene_set)
	  {
	    verboseOverMe("Trying seed gene: [$seed_query_gene].");

	    next
	      if(exists($seen_hash->{$seed_query_genome}->{$seed_query_gene}));

	    #Try to build a set (tparalogs = temporary paralogs set)
	    my @tparalogs = (grep {exists($hit_hash->{$seed_query_genome}#bidir
					  ->{$seed_query_genome}->{$_}   #check
					  ->{$seed_query_gene})}
			     keys(%{$hit_hash->{$seed_query_genome}
				      ->{$seed_query_genome}
					->{$seed_query_gene}}));

	    debug("Considering candidates as a paralogous set: [",
		  join(',',@tparalogs),"].");

	    #Make sure all paralogs hit each other
	    my @paralogs = ($seed_query_gene);
	    foreach my $paralog1 (@tparalogs)
	      {
		next if($paralog1 eq $seed_query_gene);
		my $match_missing = 0;
		foreach my $paralog2 (@paralogs)
		  {$match_missing = 1
		     if(!exists($hit_hash->{$seed_query_genome}
				->{$seed_query_genome}->{$paralog1}
				->{$paralog2}) ||
			!exists($hit_hash->{$seed_query_genome}
				->{$seed_query_genome}->{$paralog2}
				->{$paralog1}))}
		next if($match_missing);
		push(@paralogs,$paralog1);
	      }

	    #Update the seen hash so we can skip them later
	    foreach my $paralog (@paralogs)
	      {$seen_hash->{$seed_query_genome}->{$paralog}++}

	    #Keep a candidate array of arrays of genes which have been hit
	    #where the first member is the genome the genes are being added
	    #from
	    my @common_candidates = ([$seed_query_genome,@paralogs]);

	    #Skip this gene if it doesn't contain hits to all other genomes
	    if(($num_genomes - 1) >
	       scalar(grep {$_ ne $seed_query_genome}
		      keys(%{$hit_hash->{$seed_query_genome}})))
	      {next}

	    #See if every subject genome has non-empty string keys for this
	    #query gene or its paralogs
	    my $all_hit              = 1;
	    my $hit_a_subject_genome = 0;
	    foreach my $subject_genome (grep {$_ ne $seed_query_genome}
					keys(%{$hit_hash
						 ->{$seed_query_genome}}))
	      {
		$hit_a_subject_genome = 1;

		#See if there's a bidirectional hit from any query paralog to
		#each subject genome
		my $hit = 0;
		push(@common_candidates,[$subject_genome]);
		my $subject_genes_hash = {};
		foreach my $paralog (@paralogs)
		  {
		    foreach my $hitk
		      (grep {$_ ne ''}
		       grep {exists($hit_hash->{$subject_genome} #bidirectional
				    ->{$seed_query_genome}       #check
				    ->{$_}->{$paralog})}
		       keys(%{$hit_hash->{$seed_query_genome}
				->{$subject_genome}->{$paralog}}))
			{$subject_genes_hash->{$hitk} = 1}

		    #If the hits marked are good (assumes first one in the hash
		    #is sufficient), say that there is a hit to this subject
		    #genome
		    if(scalar(keys(%$subject_genes_hash)) &&
		       (keys(%$subject_genes_hash))[0] =~ /\S/)
		      {$hit = 1}
#The code below was leading to duplicate paralogs when multiple seeds were
#hitting the same genes in the subject genomes, so I implemented the code above
#and in the else below this loop to make the subject list of genes unique
#	    push(@{$common_candidates[-1]},
#		 grep {$_ ne ''}
#		 grep {exists($hit_hash->{$subject_genome}  #bidirectional
#			      ->{$seed_query_genome}        #check
#			      ->{$_}->{$paralog})}
#		 keys(%{$hit_hash->{$seed_query_genome}->{$subject_genome}
#			  ->{$paralog}}));
#	    if(scalar(@{$common_candidates[-1]}) > 1 &&
#	       $common_candidates[-1][1] =~ /\S/)
#	      {$hit = 1}
		  }

		#If there was not a bidirectional hit to this subject genome,
		#we can stop, because everything must hit everything
		if(!$hit)
		  {
		    $all_hit = 0;
		    last;
		  }
		else
		  {
		    foreach my $sgene (keys(%$subject_genes_hash))
		      {$seen_hash->{$subject_genome}->{$sgene}++}
		    push(@{$common_candidates[-1]},keys(%$subject_genes_hash));
		  }
	      }

	    #If the seed gene bidirectionally hits everything
	    if($all_hit && $hit_a_subject_genome)
	      {push(@$common_groups,[@common_candidates])}
	    #Or if there's only one genome and we're gathering paralogous sets
	    #to simulate a core-genome for comparison purposes
	    elsif(scalar(keys(%$hit_hash)) == 1 && scalar(@paralogs))
	      {push(@$common_groups,[@common_candidates])}
	    elsif(scalar(keys(%$hit_hash)) == 1 && scalar(@paralogs) == 0)
	      {warning("This gene in [$seed_query_genome]: ",
		       "[$seed_query_gene] did not appear to hit itself ",
		       "bidirectionally.  It's either short or there are a ",
		       "bunch of copies of it (thus it dropped off the list ",
		       "of hits).")}
	  }

	foreach my $sgenome (keys(%$seen_hash))
	  {
	    my $num_problems = scalar(grep {$seen_hash->{$sgenome}->{$_} > 1}
				      keys(%{$seen_hash->{$sgenome}}));
	    if($num_problems)
	      {
		error("There appear to be [$num_problems] genes in the ",
		      "genome set for genome: [$sgenome] that can belong to ",
		      "multiple paralogous sets because some genes which do ",
		      "not bidirectionally hit each other.  This suggests ",
		      "that you should make your hit cutoffs more stringent ",
		      "or that your blast results contain short hits (which ",
		      "cannot be filtered by this script - they must be ",
		      "filtered in previous steps).  These are the genes ",
		      "which you will find in multiple groups: [",
		      join(',',grep {$seen_hash->{$sgenome}->{$_} > 1}
			   keys(%{$seen_hash->{$sgenome}})),
		      "].");
	      }
	  }

	verbose("Found ",scalar(@$common_groups),
		" candidate sets of common genes.  Validating...");

	#Now make sure everything hits everything, accounting for paralogs
	my $group_num     = 0;
	my $commons_found = 0;
	foreach my $common_group (@$common_groups)
	  {
	    $group_num++;
	    my $all_bidirectional = 1;
	    foreach my $genome (@$common_group)
	      {
		verboseOverMe("Evaluating genome [$genome->[0]] in group ",
			      "[$group_num].");
		if(!isGenomeBidirectional($genome,$common_group,$hit_hash))
		  {
		    $all_bidirectional = 0;
		    last;
		  }
	      }
	    if($all_bidirectional)
	      {
		$commons_found++;
		outputGroup($common_group,$commons_found);
	      }
	  }

	verbose("Found $commons_found common genes.");
      }
    else #Fully bidirectional
      {
	debug("Fully bidirectional mode, engaged.");

	my $commons_found = 0;

	#For each gene in the seed genome that had a hit to one of the other
	#genomes
	foreach my $seed_query_gene (@seed_gene_set)
	  {
	    next if(exists($seen_hash->{$seed_query_gene}));

	    my $genome_check = {$seed_query_genome => 1};

	    #Create an array of all the bidirectional hits with the seed
	    my $ordered_hits = {};
	    foreach my $subject_genome (keys(%{$hit_hash
						 ->{$seed_query_genome}}))
	      {
		foreach my $subject_gene
		  (keys(%{$hit_hash->{$seed_query_genome}->{$subject_genome}
			    ->{$seed_query_gene}}))
		    {

		      if(#If it's not a hit to self
			 ($seed_query_genome ne $subject_genome ||
			  $seed_query_gene ne $subject_gene) &&
			 #And the reciprocal hit exists (above cutoffs is
			 #implied by the fact it exists)
			 exists($hit_hash->{$subject_genome}
				->{$seed_query_genome}->{$subject_gene}
				->{$seed_query_gene}))
			{
			  debug("CANDIDATE: [$seed_query_genome, ",
				"$seed_query_gene -> $subject_genome, ",
				"$subject_gene \@ ",
				$hit_hash->{$seed_query_genome}
				->{$subject_genome}->{$seed_query_gene}
				->{$subject_gene}->{EVALUE},", ",
				$hit_hash->{$seed_query_genome}
				->{$subject_genome}->{$seed_query_gene}
				->{$subject_gene}->{LENGTHRATIO},"].");
			  $genome_check->{$subject_genome} = 1;
			  push(@{$ordered_hits->{$subject_genome}},
			       [$subject_gene,
				$hit_hash->{$seed_query_genome}
				->{$subject_genome}->{$seed_query_gene}
				->{$subject_gene}->{EVALUE},
			        $hit_hash->{$seed_query_genome}
				->{$subject_genome}->{$seed_query_gene}
				->{$subject_gene}->{LENGTHRATIO}]);
			}
		    }
	      }

	    #Skip this one if the seed doesn't hit every genome
	    next if(scalar(keys(%$genome_check)) < $num_genomes &&
		    #This is for when we're outputting paralogs for one genome
		    $num_genomes != 1);

	    #Order the subject hits by deviation from a length ratio of 1, then
	    #by e-value of the hit from the seed
	    foreach my $genome (keys(%$ordered_hits))
	      {@{$ordered_hits->{$genome}} =
		 sort {abs(1-$a->[2]) <=> abs(1-$b->[2]) ||
			 $a->[1] <=> $b->[1]} @{$ordered_hits->{$genome}}}

	    #This is where we will try to build our bidirectional set
	    my $candidates = {$seed_query_genome => {$seed_query_gene => 1}};

	    #See if we can get a bidirectional set from any combination of
	    #genes.
	    #Note that we will not be checking the seed gene because we already
	    #know every candidate already bidirectionally hits it
	    my $combo = [];
	    my $sizes = [map {scalar(@{$ordered_hits->{$_}})}
			 sort {$a cmp $b}
			 grep {$_ ne $seed_query_genome}
			 keys(%$ordered_hits)];
	    my $ordered_keys = [sort {$a cmp $b}
				grep {$_ ne $seed_query_genome}
				keys(%$ordered_hits)];

	    debug("Inspecting [",join(',',@$sizes),"] subject hits (for each ",
		  "subject genome) from the seed gene: [$seed_query_gene].");

	    #Cycle through all possible combinations of non-seed genome genes
	    #that the seed gene hit to see if everything hit eachother above
	    #the cutoff (i.e. it exists in the hit hash)
	    my $all_bidirec = 1;
	    while(GetNextIndepCombo($combo,$sizes))
	      {
		$all_bidirec = 1;
		for(my $genome_a_index = 0;
		    $genome_a_index < scalar(@$combo);
		    $genome_a_index++)
		  {
		    for(my $genome_b_index = $genome_a_index + 1;
			$genome_b_index < scalar(@$combo);
			$genome_b_index++)
		      {
			#Next if this is the same gene
			next if($genome_a_index == $genome_b_index &&
			        $combo->[$genome_a_index] ==
				$combo->[$genome_b_index]);

			#To make this more readable, set these temp. vars.
			my $genome_a = $ordered_keys->[$genome_a_index];
			my $genome_b = $ordered_keys->[$genome_b_index];
			my $gene_a   =
			  $ordered_hits->{$ordered_keys->[$genome_a_index]}
			    ->[$combo->[$genome_a_index]]->[0];
			my $gene_b   =
			  $ordered_hits->{$ordered_keys->[$genome_b_index]}
			    ->[$combo->[$genome_b_index]]->[0];

			#Check to see if everything hits everything
			if(#Forward Hit
			   !exists($hit_hash->{$genome_a}->{$genome_b}
				   ->{$gene_a}->{$gene_b}) ||
			   #Reciprocal Hit
			   !exists($hit_hash->{$genome_b}->{$genome_a}
				   ->{$gene_b}->{$gene_a}))
			  {
			    debug("No Recip: [$genome_a, $gene_a -> ",
				  "$genome_b, $gene_b]");
			    $all_bidirec = 0;
			    last;
			  }
		      }
		    last if(!$all_bidirec);
		  }

		#If we found a fully bidirectional set of candidates, this is
		#what we will try to expand below.
		if($all_bidirec)
		  {
		    debug("FOUND AN ALL-BIDIRECTIONAL SET FOR SEED ",
			  "[$seed_query_genome, $seed_query_gene].  ",
			  "ADDING A SUBJECT FROM EACH:");

		    my $genome_index = 0;
		    foreach my $gene_index (@$combo)
		      {
			debug("SUBJECT: [$ordered_keys->[$genome_index], ",
			      $ordered_hits->{$ordered_keys->[$genome_index]}
			      ->[$gene_index]->[0],
			      "]. [$genome_index] [$ordered_keys->[$genome_index]] [$gene_index] [$gene_index] [$ordered_hits->{$ordered_keys->[$genome_index]}->[$gene_index]->[0]]");
			#Set the candidate's genome and gene keys based on the
			#index stored in the combo array.  This should set the
			#bidirectional set that was found.
			$candidates->{$ordered_keys->[$genome_index]}
			  ->{$ordered_hits->{$ordered_keys->[$genome_index]}
			     ->[$gene_index]->[0]} = 1;
			$genome_index++;
		      }

		    last;
		  }
	      }

	    next unless($all_bidirec);

	    #Put all the hits in an array ordered by deviation from a length
	    #ratio of 1, then E Value. This will mix the hits from the various
	    #genomes together.
	    my @other_hits = sort {abs(1-$a->[1]->[2]) <=>
				     abs(1-$b->[1]->[2]) ||
				       $a->[1]->[1] <=> $b->[1]->[1]}
	      map {my $gnm=$_;map {[$gnm,$_]} @{$ordered_hits->{$_}}}
		keys(%$ordered_hits);

	    debug("Fully bidirectional seed contructed.  Trying to add more ",
		  "members.");

	    #We know that everything we have so far is fully bidirectional and
	    #consists of the best hits (greedily constructed).  Now we want to
	    #expand the bidirectional set we found to any of the other hits
	    #from the candidate set.
	    foreach my $next_best_hit (@other_hits)
	      {
		#Skip this hit if it was added before above
		next if(exists($candidates->{$next_best_hit->[0]}) &&
			exists($candidates->{$next_best_hit->[0]}
			       ->{$next_best_hit->[1]->[0]}));

		debug("Additional candidate: [$next_best_hit->[0], ",
		      "$next_best_hit->[1]->[0]].");

		my $another_bidirec = 1;
		foreach my $subject_genome (keys(%$candidates))
		  {
		    foreach my $candidate (keys(%{$candidates
						    ->{$subject_genome}}))
		      {
			if(#Forward Hit
			   !exists($hit_hash->{$next_best_hit->[0]}
				   ->{$subject_genome}->{$next_best_hit->[1]->[0]}
				   ->{$candidate}) ||
			   #Reciprocal Hit
			   !exists($hit_hash->{$subject_genome}
				   ->{$next_best_hit->[0]}->{$candidate}
				   ->{$next_best_hit->[1]->[0]}))
			  {
			    $another_bidirec = 0;
			    last;
			  }
		      }
		    last unless($another_bidirec);
		  }

		#If the gene stored in next_best_hit bidirectionally hits
		#everything, add it to the set
		if($another_bidirec)
		  {
		    debug("Adding another member to the set: ",
			  "[$next_best_hit->[0], $next_best_hit->[1]->[0]].");
		    $candidates->{$next_best_hit->[0]}->{$next_best_hit->[1]
							 ->[0]} = 1;
		  }
	      }

	    if($all_bidirec)
	      {
		#Update the seen hash so we can skip over seed paralogs
		foreach my $seed_gene (keys(%{$candidates
						->{$seed_query_genome}}))
		  {$seen_hash->{$seed_gene}++}

		$commons_found++;
		my $common_group = [];
		foreach my $genome (keys(%$candidates))
		  {push(@$common_group,
			[$genome,keys(%{$candidates->{$genome}})])}

		outputGroup($common_group,$commons_found);
	      }
	  }
      }

#    #Output paralogs if the paralogs suffix has been supplied
#    if(defined($paralogs_suffix) && $paralogs_suffix eq '')
#      {
#	error("The paralogs output file suffix must either not be supplied ",
#	      "(to not produce paralog files) or be a non-empty value.  You ",
#	      "supplied: [$paralogs_suffix], so paralogs will not be output.");
#      }
#    elsif(defined($paralogs_suffix) && $paralogs_suffix ne '')
#      {
#	foreach my $query_genome (keys(%$hit_hash))
#	  {
#	    #Skip genomes done from other input files (assuming the files all
#	    #share a common set of starting genomes)
#	    if(exists($genomes_done_hash->{$query_genome}))
#	      {next}
#	    else
#	      {$genomes_done_hash->{$query_genome} = 1}
#
#	    #Open the output paralog file
#	    my $outfile = $parent_dir . $query_genome . $paralogs_suffix;
#	    if(open(PARALOG,">$outfile"))
#	      {
#		verboseOverMe("[$outfile] Opened uniques output file.");
#		select(PARALOG);
#	      }
#	    else
#	      {
#		error("Unable to write to file: [$outfile].");
#		next;
#	      }
#
#	    #Get all the query genes
#	    my @gene_set = keys(%{$hit_hash->{$query_genome}
#				    ->{$query_genome}});
#	    my $seen_hash = {};
#
#	    #Go through each query gene
#	    foreach my $query_gene (@gene_set)
#	      {
#		#Skip paralogs already printed
#		next if(exists($seen_hash->{$query_gene}));
#
#		#Obtain bidirectional hit paralogs (including hits to self)
#		my @paralogs = (grep {exists($hit_hash->{$query_genome} #bidir.
#					     ->{$query_genome}->{$_}    #check
#					     ->{$query_gene})}
#				keys(%{$hit_hash->{$query_genome}
#					 ->{$query_genome}->{$query_gene}}));
#
#		#Update the seen hash so we can skip them later
#		foreach my $paralog (@paralogs)
#		  {$seen_hash->{$paralog} = 1}
#
#		if(scalar(@paralogs) == 0)
#		  {
#		    $seen_hash->{$query_gene} = 1;
#		    push(@paralogs,$query_gene);
#		  }
#
#		#Print the set of paralogs on one line (which may be a unique
#		#non-paralogous gene)
#		print(join("\t",@paralogs),"\n");
#	      }
#
#	    select(STDOUT);
#	    close(PARALOG);
#	    verbose("[$outfile] Output file done.");
#	  }
#      }

    #If an output file name suffix is set
    if(defined($outfile_suffix))
      {
	#Select standard out
	select(STDOUT);
	#Close the output file handle
	close(OUTPUT);

	verbose("[$current_output_file] Output file done.");
      }
  }



#Report the number of errors, warnings, and debugs
verbose("Done.  EXIT STATUS: [",
	"ERRORS: ",
	($main::error_number ? $main::error_number : 0),
	" WARNINGS: ",
	($main::warning_number ? $main::warning_number : 0),
	($DEBUG ?
	 " DEBUGS: " . ($main::debug_number ? $main::debug_number : 0) : ''),
        " TIME: ",scalar(markTime(0)),"s]");
if($main::error_number || $main::warning_number)
  {verbose("Scroll up to inspect errors and warnings.")}

##
## End Main
##






























##
## Subroutines
##


#This sub has a "bag" for each position being incremented.  in other words, the
#$pool_size is an array of values equal in size to the $set_size
sub GetNextIndepCombo
  {
    #Read in parameters
    my $combo      = $_[0];  #An Array of numbers
    my $pool_sizes = $_[1];  #An Array of numbers indicating the range for each
                             #position in $combo

    if(ref($combo) ne 'ARRAY' ||
       scalar(grep {/\D/} @$combo))
      {
	print STDERR ("ERROR:ordered_digit_increment.pl:GetNextIndepCombo:",
		      "The first argument must be an array reference to an ",
		      "array of integers.\n");
	return(0);
      }
    elsif(ref($pool_sizes) ne 'ARRAY' ||
	  scalar(grep {/\D/} @$pool_sizes))
      {
	print STDERR ("ERROR:ordered_digit_increment.pl:GetNextIndepCombo:",
		      "The second argument must be an array reference to an ",
		      "array of integers.\n");
	return(0);
      }

    my $set_size   = scalar(@$pool_sizes);

    #Initialize the combination if it's empty (first one) or if the set size
    #has changed since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	#Empty the combo
	@$combo = ();
	#Fill it with zeroes
        @$combo = (split('','0' x $set_size));
	#Return true
        return(1);
      }

    my $cur_index = $#{$combo};

    #Increment the last number of the combination if it is below the pool size
    #(minus 1 because we start from zero) and return true
    if($combo->[$cur_index] < ($pool_sizes->[$cur_index] - 1))
      {
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == ($pool_sizes->[$cur_index] - 1) &&
	  $cur_index >= 0)
      {
	#Decrement the current number index
        $cur_index--;
      }

    #If we've gone past the beginning of the combo array
    if($cur_index < 0)
      {
	@$combo = ();
	#Return false
	return(0);
      }

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{$combo})
      {
	#Set its value equal to 0
	$combo->[$_] = 0;
      }

    #Return true
    return(1);
  }

sub isGenomeBidirectional
  {
    my $gene_list    = $_[0];
    my $common_group = $_[1];
    my $hit_hash     = $_[2];

    my $genome1 = $gene_list->[0];
    my $genes1  = [@{$gene_list}[1..$#{$gene_list}]];
    my $is_bidirectional = 1;

    foreach my $gene_array (@$common_group)
      {
	my $genome2 = $gene_array->[0];
	my $genes2  = [@{$gene_array}[1..$#{$gene_array}]];
	my $forward_hit_exists    = 0;
	my $reciprocal_hit_exists = 0;

	next if($genome1 eq $genome2);

	#See if there is a hit from a paralog in genome 1 to a paralog in
	#genome 2 and if there is a hit from a paralog in genome 2 to a paralog
	#in genome 1
	foreach my $gene1 (@$genes1)
	  {
	    foreach my $gene2 (@$genes2)
	      {
		if(exists($hit_hash->{$genome1}->{$genome2}) &&
		   exists($hit_hash->{$genome1}->{$genome2}
			  ->{$gene1}->{$gene2}))
		  {$forward_hit_exists = 1}
		if(exists($hit_hash->{$genome2}->{$genome1}) &&
		   exists($hit_hash->{$genome2}->{$genome1}
			  ->{$gene2}->{$gene1}))
		  {$reciprocal_hit_exists = 1}
		last if($forward_hit_exists && $reciprocal_hit_exists);
	      }
	    last if($forward_hit_exists && $reciprocal_hit_exists);
	  }
	unless($forward_hit_exists && $reciprocal_hit_exists)
	  {
	    $is_bidirectional = 0;
	    last;
	  }
      }

    return($is_bidirectional);
  }

sub outputGroup
  {
    my $common_group = $_[0];
    my $group_number = $_[1];
    print("Group $group_number\n");
    foreach my $array (@$common_group)
      {print("\t",join("\t",@$array),"\n")}
  }

##
## This subroutine prints a description of the script and it's input and output
## files.
##
sub help
  {
    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Print a description of this program
    print << "end_print";

$script
Copyright 2007
Robert W. Leach
Created on 4/22/2008
Last Modified on $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script takes a table of blast results generated by
                bidirectional_blast.pl and a series of cutoffs and generates
                sets of "common genes" among all the blasted genomes which all
                hit one another.  Note that some data could yield duplicate
                gene IDs spread among different common groups.  This can be due
                to gene fragmentation, fusion proteins, or duplicate sequence.
                This script does not look for bidirectional best hits, but all
                bidirectional hits above a cutoff.  This is to accommodate
                fragmented sequence data.

                Reference Mode (see --fully-bidirectional)

                First, a seed genome is arbitrarily selected and the genes are
                sorted into paralogous sets where each gene hits all other
                genes.  The genes that each individual paraogous gene
                bidirectionally hits in other genomes are gathered as a
                candidate set of common genes.  If any genome lacks a
                bidirectional hit, the paralogous seed set is discarded.  Then
                each gene set from each genome is then queried for
                bidirectional hits against at least one gene in all the other
                sets.  Thus, if you consider each set of genes from a
                particular genome to be a sinlge gene, then each output group
                represents a fully bidirectional set of common genes.  Note,
                it is possible that two hit genes in a non-seed genome could be
                grouped in a set that do not hit each other bidirectionally,
                however with stringent hit cutoffs, this should represent
                negligible error in the number of groups output.  Errors are
                output if a gene is found in multiple groups.

                Fully Bidirectional Mode (see --fully-bidirectional)

                In this mode, a seed genome is chosen.  Each gene of the seed
                genome is interrogated for bidirectional hits to all other
                genomes.  If some are found in every other genome, all
                combinations of one gene from each genome is inspected to see
                that they are fully bidirectional.  Once one gene from each
                genome is found, the remaining hits (from any genome) are
                tested to see if they can be added to the final set and still
                be fully bidirectional.

* INPUT FORMAT: Generate input files using the standard output from
                bidirectional_blast.pl.  Optionally, an additional column may
                be added to indicate that the association between the two
                sequences was generated by a means other than by directly
                blasting the pair together.  This is to be able to deal with
                fragmentary data from a sequencer.  Each pool of fragments can
                be blasted against a reference set of unique sequences (a
                uniref cluster is recommended) and then fragments that hit the
                same reference sequence can be put on the same line (twice -
                reversing the order on the other to simulate a bidirectional
                pair of hits).  In the last optional column, you can add the
                reference sequence ID that they both hit.  It is also
                recommended that you place the worst blast scores (evalue,
                match length ratio, and percent similarity) of one of the hits
                to the uniref sequence on each line.  You should also only
                blast fragments to uniref that are of a minimum length that
                will ensure a unique hit.  Note that results will be subject to
                an undetermined degree of error introduced by an situation
                where a fragment hits a reference sequence that is not actually
                where the fragment belongs.  If the last column is empty, the
                hit will be assumed to be the result of a direct blast between
                fragments.  Note that this script will prefer a direct blast
                result over an indirect blast result.

* OUTPUT FORMAT: Multi-line formatted output like this:

                   Group 1
                        fasta_file_name1     gene_id1
                        fasta_file_name2     gene_id2     gene_id3
                   ...

                 where each fasta file name represents the genome the gene(s)
                 following it are from.  There will be multiple genes on a line
                 if the genome contains paralogs.

end_print
#* OUTPUT UNIQUES FORMAT: Each line contains a tab-delimited set of bi-
#                         directional paralogous gene ID's.  The number of lines
#                         is the number of unique genes.  Example:
#
#                           gene_id1
#                           gene_id2     gene_id3
#                           ...
#
#                         These output files are only generated if a uniques
#                         file suffix is supplied on the command line (-u).
#                         The file name will consist of the unique contents of
#                         the first column of the input blast table with the
#                         appended suffix.  (e.g. -u .unique yields
#                         genome1.uniques.)
#
#end_print

    return(0);
  }

##
## This subroutine prints a usage statement in long or short form depending on
## whether "no descriptions" is true.
##
sub usage
  {
    my $no_descriptions = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Grab the first version of each option from the global GetOptHash
    my $options = '[' .
      join('] [',
	   grep {$_ ne '-i'}        #Remove REQUIRED params
	   map {my $key=$_;         #Save the key
		$key=~s/\|.*//;     #Remove other versions
		$key=~s/(\!|=.)$//; #Remove trailing getopt stuff
		$key = (length($key) > 1 ? '--' : '-') . $key;} #Add dashes
	   grep {$_ ne '<>'}        #Remove the no-flag parameters
	   keys(%$GetOptHash)) .
	     ']';

    print << "end_print";
USAGE: $script -i "input file(s)" $options
       $script $options < input_file
end_print

    if($no_descriptions)
      {print("Execute $script with no options to see a description of the ",
             "available parameters.\n")}
    else
      {
        print << 'end_print';

     -i|--input-file*     REQUIRED Space-separated input hit table(s inside
                                   quotes) generated by bidirectional_blast.pl.
                                   *No flag required.  Standard input via
                                   redirection is acceptable.  Perl glob
                                   characters (e.g. '*') are acceptable inside
                                   quotes.
     -e|--evalue-cutoff   OPTIONAL [10**-30] (10**-30 means 10 to the negative
                                   thirtieth).  Cutoff E-Value under which a
                                   blast hit must score to be retained.
                                   Inclusive.
     -l|--length-ratio-   OPTIONAL [0.9] The minimum match length ratio a hit
        cutoff                     must be as compared to the longer gene in
                                   order to be retained.  Inclusive.
     -p|--percent-        OPTIONAL [10] The minimum percent identity a blast
        identity-cutoff            hit must be to be retained.  Inclusive.
     -b|--fully-          OPTIONAL [Off] The default behavior is "Reference
        bidirectional              Mode" which arbitrarily selects a reference
                                   genome and has a loose requirement for
                                   bidirectional hits.  See --help for more
                                   details.
     -o|--outfile-suffix  OPTIONAL [nothing] This suffix is added to the input
                                   file names to use as output files.
                                   Redirecting a file into this script will
                                   result in the output file name to be "STDIN"
                                   with your suffix appended.
     -f|--force           OPTIONAL [Off] Force overwrite of existing output
                                   files (generated from previous runs of this
                                   script).  Only used when the -o option is
                                   supplied.
     -v|--verbose         OPTIONAL [Off] Verbose mode.  Cannot be used with the
                                   quiet flag.
     -q|--quiet           OPTIONAL [Off] Quiet mode.  Turns off warnings and
                                   errors.  Cannot be used with the verbose
                                   flag.
     -h|--help            OPTIONAL [Off] Help.  Use this option to see an
                                   explanation of the script and its input and
                                   output files.
     --version            OPTIONAL [Off] Print software version number.  If
                                   verbose mode is on, it also prints the
                                   template version used to standard error.
     --debug              OPTIONAL [Off] Debug mode.

end_print
#     -u|--uniques-suffix  OPTIONAL [nothing] This suffix is added to genome
#                                   file names to output files containing all
#                                   the unique genes in each genome.  Paralogous
#                                   sets are reported on the same line.
      }

    return(0);
  }


##
## Subroutine that prints formatted verbose messages.  Specifying a 1 as the
## first argument prints the message in overwrite mode (meaning subsequence
## verbose, error, warning, or debug messages will overwrite the message
## printed here.  However, specifying a hard return as the first character will
## override the status of the last line printed and keep it.  Global variables
## keep track of print length so that previous lines can be cleanly
## overwritten.
##
sub verbose
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 1 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

    #Ignore the overwrite flag if STDOUT will be mixed in
    $overwrite_flag = 0 if(isStandardOutputToTerminal());

    #Read in the message
    my $verbose_message = join('',@_);

    $overwrite_flag = 1 if(!$overwrite_flag && $verbose_message =~ /\r/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\n|\t/)
	  {
	    warning("Hard returns and tabs cause overwrite mode to not work ",
		    "properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if(!$overwrite_flag)
      {$verbose_length = 0}
    elsif($verbose_message =~ /\n([^\n]*)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

    #Overwrite the previous verbose message by appending spaces just before the
    #first hard return in the verbose message IF THE VERBOSE MESSAGE DOESN'T
    #BEGIN WITH A HARD RETURN.  However note that the length stored as the
    #last_verbose_size is the length of the last line printed in this message.
    if($verbose_message =~ /^([^\n]*)/ && $main::last_verbose_state &&
       $verbose_message !~ /^\n/)
      {
	my $append = ' ' x ($main::last_verbose_size - length($1));
	unless($verbose_message =~ s/\n/$append\n/)
	  {$verbose_message .= $append}
      }

    #If you don't want to overwrite the last verbose message in a series of
    #overwritten verbose messages, you can begin your verbose message with a
    #hard return.  This tells verbose() to not overwrite the last line that was
    #printed in overwrite mode.

    #Print the message to standard error
    print STDERR ($verbose_message,
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }

sub verboseOverMe
  {verbose(1,@_)}

##
## Subroutine that prints errors with a leading program identifier containing a
## trace route back to main to see where all the subroutine calls were from,
## the line number of each call, an error number, and the name of the script
## which generated the error (in case scripts are called via a system call).
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split("\n",join('',@_));
    pop(@error_message) if($error_message[-1] !~ /\S/);

    $main::error_number++;

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Assign the values from the calling subroutines/main
    my @caller_info = caller(0);
    my $line_num = $caller_info[2];
    my $caller_string = '';
    my $stack_level = 1;
    while(@caller_info = caller($stack_level))
      {
	my $calling_sub = $caller_info[3];
	$calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	$calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	$caller_string .= "$calling_sub(LINE$line_num):"
	  if(defined($line_num));
	$line_num = $caller_info[2];
	$stack_level++;
      }
    $caller_string .= "MAIN(LINE$line_num):";

    my $leader_string = "ERROR$main::error_number:$script:$caller_string ";

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@error_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $error_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that prints warnings with a leader string containing a warning
## number
##
sub warning
  {
    return(0) if($quiet);

    $main::warning_number++;

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split("\n",join('',@_));
    pop(@warning_message) if($warning_message[-1] !~ /\S/);

    my $leader_string = "WARNING$main::warning_number: ";

    #Figure out the length of the first line of the error
    my $warning_length = length(($warning_message[0] =~ /\S/ ?
				 $leader_string : '') .
				$warning_message[0]);

    #Put leader string at the beginning of each line of the message
    foreach my $line (@warning_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $warning_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that gets a line of input and accounts for carriage returns that
## many different platforms use instead of hard returns.  Note, it uses a
## global array reference variable ($infile_line_buffer) to keep track of
## buffered lines from multiple file handles.
##
sub getLine
  {
    my $file_handle = $_[0];

    #Set a global array variable if not already set
    $main::infile_line_buffer = {} if(!defined($main::infile_line_buffer));
    if(!exists($main::infile_line_buffer->{$file_handle}))
      {$main::infile_line_buffer->{$file_handle}->{FILE} = []}

    #If this sub was called in array context
    if(wantarray)
      {
	#Check to see if this file handle has anything remaining in its buffer
	#and if so return it with the rest
	if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) > 0)
	  {
	    return(@{$main::infile_line_buffer->{$file_handle}->{FILE}},
		   map
		   {
		     #If carriage returns were substituted and we haven't
		     #already issued a carriage return warning for this file
		     #handle
		     if(s/\r\n|\n\r|\r/\n/g &&
			!exists($main::infile_line_buffer->{$file_handle}
				->{WARNED}))
		       {
			 $main::infile_line_buffer->{$file_handle}->{WARNED}
			   = 1;
			 warning("Carriage returns were found in your file ",
				 "and replaced with hard returns");
		       }
		     split(/(?<=\n)/,$_);
		   } <$file_handle>);
	  }
	
	#Otherwise return everything else
	return(map
	       {
		 #If carriage returns were substituted and we haven't already
		 #issued a carriage return warning for this file handle
		 if(s/\r\n|\n\r|\r/\n/g &&
		    !exists($main::infile_line_buffer->{$file_handle}
			    ->{WARNED}))
		   {
		     $main::infile_line_buffer->{$file_handle}->{WARNED}
		       = 1;
		     warning("Carriage returns were found in your file ",
			     "and replaced with hard returns");
		   }
		 split(/(?<=\n)/,$_);
	       } <$file_handle>);
      }

    #If the file handle's buffer is empty, put more on
    if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) == 0)
      {
	my $line = <$file_handle>;
	if(!eof($file_handle))
	  {
	    if($line =~ s/\r\n|\n\r|\r/\n/g &&
	       !exists($main::infile_line_buffer->{$file_handle}->{WARNED}))
	      {
		$main::infile_line_buffer->{$file_handle}->{WARNED} = 1;
		warning("Carriage returns were found in your file and ",
			"replaced with hard returns");
	      }
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} =
	      split(/(?<=\n)/,$line);
	  }
	else
	  {
	    #Do the \r substitution for the last line of files that have the
	    #eof character at the end of the last line instead of on a line by
	    #itself.  I tested this on a file that was causing errors for the
	    #last line and it works.
	    $line =~ s/\r/\n/g if(defined($line));
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} = ($line);
	  }
      }

    #Shift off and return the first thing in the buffer for this file handle
    return($_ = shift(@{$main::infile_line_buffer->{$file_handle}->{FILE}}));
  }

##
## This subroutine allows the user to print debug messages containing the line
## of code where the debug print came from and a debug number.  Debug prints
## will only be printed (to STDERR) if the debug option is supplied on the
## command line.
##
sub debug
  {
    return(0) unless($DEBUG);

    $main::debug_number++;

    #Gather and concatenate the error message and split on hard returns
    my @debug_message = split("\n",join('',@_));
    pop(@debug_message) if($debug_message[-1] !~ /\S/);

    #Assign the values from the calling subroutine
    #but if called from main, assign the values from main
    my($junk1,$junk2,$line_num,$calling_sub);
    (($junk1,$junk2,$line_num,$calling_sub) = caller(1)) ||
      (($junk1,$junk2,$line_num) = caller());

    #Edit the calling subroutine string
    $calling_sub =~ s/^.*?::(.+)$/$1:/ if(defined($calling_sub));

    my $leader_string = "DEBUG$main::debug_number:LINE$line_num:" .
      (defined($calling_sub) ? $calling_sub : '') .
	' ';

    #Figure out the length of the first line of the error
    my $debug_length = length(($debug_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $debug_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@debug_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $debug_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## This sub marks the time (which it pushes onto an array) and in scalar
## context returns the time since the last mark by default or supplied mark
## (optional) In array context, the time between all marks is always returned
## regardless of a supplied mark index
## A mark is not made if a mark index is supplied
## Uses a global time_marks array reference
##
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set to contain (as the first
    #element) the time the program started (NOTE: "$^T" is a perl variable that
    #contains the start time of the script)
    $main::time_marks = [$^T] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error("Supplied time mark index is larger than the size of the ",
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = $time - $main::time_marks->[$mark_index];

    #Add the current time to the time marks array
    push(@$main::time_marks,$time)
      if(!defined($_[0]) || scalar(@$main::time_marks) == 0);

    #If called in array context, return time between all marks
    if(wantarray)
      {
	if(scalar(@$main::time_marks) > 1)
	  {return(map {$main::time_marks->[$_ - 1] - $main::time_marks->[$_]}
		  (1..(scalar(@$main::time_marks) - 1)))}
	else
	  {return(())}
      }

    #Return the time since the time recorded at the supplied time mark index
    return($time_since_mark);
  }

##
## This subroutine reconstructs the command entered on the command line
## (excluding standard input and output redirects).  The intended use for this
## subroutine is for when a user wants the output to contain the input command
## parameters in order to keep track of what parameters go with which output
## files.
##
sub getCommand
  {
    my $perl_path_flag = $_[0];
    my($command);

    #Determine the script name
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Put quotes around any parameters containing un-escaped spaces or astericks
    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\\)[\s\*]/ || $arg eq '')
	 {$arg = "'" . $arg . "'"}}

    #Determine the perl path used (dependent on the `which` unix built-in)
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }

    #Build the original command
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }

##
## This subroutine checks to see if a parameter is a single file with spaces in
## the name before doing a glob (which would break up the single file name
## improperly).  The purpose is to allow the user to enter a single input file
## name using double quotes and un-escaped spaces as is expected to work with
## many programs which accept individual files as opposed to sets of files.  If
## the user wants to enter multiple files, it is assumed that space delimiting
## will prompt the user to realize they need to escape the spaces in the file
## names.
##
sub sglob
  {
    my $command_line_string = $_[0];
    return(-e $command_line_string ?
	   $command_line_string : glob($command_line_string));
  }


sub printVersion
  {
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;
    print(($verbose ? "$script Version " : ''),
	  $software_version_number,
	  "\n");
    verbose("Generated using perl_script_template.pl\n",
	    "Version $template_version_number\n",
	    "Robert W. Leach\n",
	    "robleach\@lanl.gov\n",
	    "5/8/2006\n",
	    "Los Alamos National Laboratory\n",
	    "Copyright 2006");
    return(0);
  }

#This subroutine is a check to see if input is user-entered via a TTY (result is non-
#zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note, explicit prints
#to STDOUT when another output handle is selected are not considered and may defeat this
#subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}
