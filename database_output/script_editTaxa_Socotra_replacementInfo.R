## Socotra Project :: script_editTaxa_Socotra_replacementInfo.R
# ==============================================================================
# 11 March 2016
# Author: Flic Anderson
#
# objects created: taxaFixes
# saved at: O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra_replacementInfo.R
# dependent on: "O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra.R"
# source("O://CMEP\ Projects/Scriptbox/database_output/script_editTaxa_Socotra_replacementInfo.R")
#
# AIM:  Contains the replacements/lumping of Socotran taxa for better analysis, 
# ....  cuts down on unique taxa. 
# ....  Mainly deals with "A b subsp./var. b" situations, so these have all been
# ....  lumped as "A b". Where there are a species ("A b") AND a subspecies which 
# ....  is NOT an autonym (ie it may be "A b subsp/var c"), this has been lumped 
# ....  as "A b".  Where there are several subspecies ("A b subsp/var b", "A b 
# ....  subsp/var c", "A b subsp/var d"), these have all been lumped into "A b".
# ....  Where there's only "A b subsp c", these were left as they were as there's
# ....  no real option for confusion with other levels of taxa.
# ....  
# ---------------------------------------------------------------------------- #


toReplace <- c("Achyranthes aspera L. var. aspera",
"Achyranthes aspera var. pubescens (Moq.) C.C.Towns.",
"Aerva javanica (Burm.f.) Juss. var. javanica",
"Aerva javanica var. bovei Webb",
"Amaranthus graecizans L. subsp. graecizans",
"Adenium obesum subsp. sokotranum (Vierh.) Lavranos",
"Digera muricata subsp. trinervis var. patentipilosa C.C.Towns.",
"Digera muricata var. patentipilosa C.C.Towns.",
"Asparagus africanus var. microcarpus Balf.f.",
"Cordia crenata Delile subsp. crenata",
"Commiphora ornifolia var. glabra (Radcl.-Sm.) J.B.Gillett",
"Wahlenbergia lobelioides subsp. nutabunda (Guss.) Murb.",
"Capparis spinosa L. var. spinosa",
"Maerua angolensis subsp. socotrana (Schweinf. ex Balf.f.) Kers",
"Maerua angolensis var. socotrana Schweinf. ex Balf.f.",
"Arenaria foliacea Turrill",
"Arenaria leptoclados (Rchb.) Guss.",
"Gypsophila montana subsp. somalensis (Franch.) M.G.Gilbert",
"Lochia bracteata Balf.f. subsp. bracteata",
"Polycarpaea spicata Wight ex Arn. var. spicata",
"Polycarpaea spicata var. capillaris Balf.f.",
"Atriplex griffithii subsp. stocksii (Boiss.) Boulos",
"Convolvulus siculus subsp. agrestis (Schweinf.) Verdc.",
"Ipomoea pes-caprae subsp. pes-caprae",
"Ipomoea sinensis (Desr.) Choisy subsp. sinensis",
"Ipomoea sinensis subsp. blephariosepala (Hochst. ex A.Rich.) Verdc. ex A.Meeuse",
"Ipomoea sinensis var. blepharosepala (A.Rich.) Meese",
"Seddera glomerata subsp. glomerata",
"Crassula alata subsp. pharnaceoides (Fisch. & C.A.Mey.) Wickens & Bywater",
"Crassula schimperi subsp. phyturus (Mildbr.) R.Fern.",
"Cucumis prophetarum L. subsp. prophetarum",
"Cucumis prophetarum var. prophetarum L.",
"Cucumis prophetarum subsp. dissectus (Naudin) C.Jeffrey",
"Cucumis prophetarum var. dissectus (Naudin) C.Jeffrey",
"Carex steudneri subsp. socotrana ined.",
"Cyperus umbellatus forma cyperinus (Retz.) C.B.Clarke",
"Fimbristylis cymosa var. spathacea (Roth) T. Koyama",
"Andrachne schweinfurthii var. papillosa Radcl.-Sm.",
"Andrachne somalensis Pax var. somalensis",
"Andrachne somalensis Pax",
"Euphorbia arbuscula var. montana Balf.f.",
"Euphorbia balsamifera subsp. adenensis (Deflers) P.R.O.Bally",
"Euphorbia schweinfurthii Balf.f. subsp. A (typical)",
"Euphorbia schweinfurthii Balf.f. subsp. B", 
"Euphorbia schweinfurthii Balf.f. subsp. C",
"Euphorbia schweinfurthii Balf.f. subsp. D",
"Cymbopogon jwarancusa subsp. olivieri (Boiss.) Soenarko", 
"Eleusine coracana subsp. africana (Kenn.-O'Byrne) S.M.Philips",
"Melinis repens subsp. grandiflora (Hochst.) Zizka", 
"Hypericum socotranum R.D.Good subsp. socotranum",
"Hypericum socotranum subsp. smithii N.Robson",
#"Micromeria biflora subsp. arabica K.H.Walther",
"Micromeria imbricata (Forssk.) C.Chr. var. imbricata",
"Otostegia fruticosa subsp. fruticosa",
"Vachellia oerfota var. brevifolia (Boulos) Kyal. & Boatwr.",
"Indigofera coerulea Roxb. var. coerulea", 
"Indigofera coerulea var. occidentalis J.B.Gillett",
"Indigofera tinctoria L. var. tinctoria",
"Microcharis disjuncta var. fallax (J.B.Gillett) Schrire",
"Rhynchosia minima (L.) DC. var. minima",
"Teramnus repens subsp. gracilis (Chiov.) Verdc.",
"Jasminum fluminense subsp. socotranum P.S.Green",
"Anagallis arvensis var. caerulea (L.) Gouan",
"Diodia aulacosperma var. angustata Verdc.",
"Galium spurium subsp. africanum Verdc.",
"Galium spurium var. africanum Verdc.",
"Kohautia subverticellata subsp. eritreensis (Bremek.) D.Mantell ex Puff",
"Oldenlandia corymbosa var. caespitosa (Benth.) Verdc.",
"Dodonaea viscosa subsp. angustifolia (L.f.) J.G.West",
"Solanum villosum subsp. miniatum (Bernh. ex Willd. ) Edmonds",
"Sterculia africana (Lour.) Fiori subsp. africana",
"Sterculia africana subsp. socotrana Abedin",
"Viola cinerea Boiss. var. stocksii", 
"Capparis spinosa L.",
"Ficus cordata subsp. salicifolia (Vahl) C.C.Berg",
"Heliotropium aff. socotranum Vierh.",
"Aloe sp. nov. ined.",
"Carex steudneri subsp. socotrana Repka & Madera",
"Amaranthus graecizans subsp. thellunganianus (Nevski) Gusev")

replaceWith <- c("Achyranthes aspera L.",
"Achyranthes aspera L.",
"Aerva javanica (Burm.f.) Juss.",
"Aerva javanica (Burm.f.) Juss.",
"Amaranthus graecizans L.",
"Adenium obesum (Forssk.) Roem. & Schult.",
"Digera muricata (L.) Mart.",
"Digera muricata (L.) Mart.",
"Asparagus africanus Lam.",
"Cordia crenata Delile",
"Commiphora ornifolia (Balf.f.) J.B.Gillett",
"Wahlenbergia lobelioides DC.",
"Capparis spinosa L.",
"Maerua angolensis DC.",
"Maerua angolensis DC.",
"Arenaria serpyllifolia L.",
"Arenaria serpyllifolia L.",
"Gypsophila montana Balf.f.",
"Lochia bracteata Balf.f.",
"Polycarpaea spicata Wight ex Arn.",
"Polycarpaea spicata Wight ex Arn.",
"Atriplex griffithii Moq.",
"Convolvulus siculus L.",
"Ipomoea pes-caprae (L.) R.Br.",
"Ipomoea sinensis (Desr.) Choisy",
"Ipomoea sinensis (Desr.) Choisy",
"Ipomoea sinensis (Desr.) Choisy",
"Seddera glomerata (Balf.f.) O.Schwartz",
"Crassula alata (Viv.) A.Berger",
"Crassula schimperi Fisch. & C.A.Mey.",
"Cucumis prophetarum L.",
"Cucumis prophetarum L.",
"Cucumis prophetarum L.",
"Cucumis prophetarum L.",
"Carex steudneri Boeck.",
"Cyperus cyperinus (Retz.) Valck.-Sur.",
"Fimbristylis cymosa R.Br.",
"Andrachne schweinfurthii (Balf.f.) Radcl.-Sm.",
"Andrachne schweinfurthii (Balf.f.) Radcl.-Sm.",
"Andrachne schweinfurthii (Balf.f.) Radcl.-Sm.",
"Euphorbia arbuscula Balf.f.",
"Euphorbia balsamifera Aiton",
"Euphorbia schweinfurthii Balf.f.",
"Euphorbia schweinfurthii Balf.f.",
"Euphorbia schweinfurthii Balf.f.",
"Euphorbia schweinfurthii Balf.f.",
"Cymbopogon jwarancusa (Jones) Schult.", 
"Eleusine coracana (L.) Gaertn.",
"Melinis repens (Willd.) Zizka",
"Hypericum socotranum R.D.Good",
"Hypericum socotranum R.D.Good",
#"Micromeria imbricata (Forssk.) C.Chr.",
"Micromeria imbricata (Forssk.) C.Chr.",
"Otostegia fruticosa (Forssk.) Schweinf. ex Penz.",
"Vachellia oerfota (Forssk.) Kyal. & Boatwr.",
"Indigofera coerulea Roxb.", 
"Indigofera coerulea Roxb.", 
"Indigofera tinctoria L.",
"Microcharis disjuncta (J.B.Gillett) Schrire",
"Rhynchosia minima (L.) DC.",
"Teramnus repens (Taub.) Baker f.",
"Jasminum fluminense Vell.",
"Anagallis arvensis L.",
"Diodia aulacosperma K.Schum.",
"Galium spurium L.",
"Galium spurium L.",
"Kohautia subverticellata (K.Schum.) D.Mantell", 
"Oldenlandia corymbosa L.", 
"Dodonaea viscosa Jacq.",
"Solanum villosum (L.) Mill.",
"Sterculia africana (Lour.) Fiori",
"Sterculia africana (Lour.) Fiori",
"Viola cinerea Boiss.",
"Capparis cartilaginea Decne.",
"Ficus cordata Thunb.",
"Heliotropium socotranum Vierh.",
"Aloe jawiyon S.J.Christie, D.P.Hannon & N.Oakman ex A.G.Mill.",
"Carex steudneri Boeck.",
"Amaranthus graecizans L.")

taxaFixes <<- data.frame(toReplace, replaceWith)

# dubiousList <- c(
#         "Boswellia nana x socotrana", # hybrid
#         "Boswellia aff. ameero Balf.f.", # 1x 17k Miller, 1x Hein
#         "Corchorus trilocularis L.", # 3x 10k Miller recs
#         "Cryptolepis orbicularis Chiov.", # few recs
#         "Cuscuta pretoriana Yunck.", # 1 rec only
#         "Cymbopogon schoenanthus (L.) Spreng",  # old lit
#         "Cymodocea rotundata Asch. & Schweinf.", # old lit
#         "Cymodocea serrulata (R.Br.) Asch. & Magnus", # old lit
#         "Cyperus tegetum Roxb.", # old lit
#         "Delphinium sheilae Kit Tan", # 1x 10k Miller, det notes say "Lichen"?!?!, 
#         "Dipterygium glaucum Decne.",  # 1x 10K Miller
#         "Echidnopsis socotrana X insularis",  # hybrid
#         "Echiochilon persicum (Burm.f.) I.M.Johnst.", # hist + syn(?) E. albidum by Czech team
#         "Eleocharis chaetaria (L.) Roem. & Schult.", # old lit
#         "Eleusine africana Kenn.-O'Byrne",  # 1x Schweinf, prob refers to Eleusine coracana
#         "Eragrostis patula (Kunth) Steud.",  # 1x Thulin
#         "Eragrostis pilosa (L.) P.Beauv.", # old lit
#         "Foeniculum vulgare Mill.", # old lit
#         "Glossonema varians (Stocks) Benth. ex Hook.f.", # 1x 31k Miller fieldrec
#         "Grewia damine Gaertn.", # 1x 10k Miller
#         "Halodule uninervis (Forrsk.) Aschers",  # old lit
#         "Helichrysum profusum Balf.f.", # 2x old recs(1x lit, 1x Schweinf)
#         "Juncus maritimus Lam.", # old lit
#         "Limonium guigliae Raimondo & Domina",  # only type record
#         "Najas major L.", # old lit
#         "Otostegia fruticosa (Forssk.) Schweinf. ex Penz.", # one Hein
#         "Peperomia abyssinica Miq.", # 1x 31k Miller field 
#         "Striga linearifolia (Schumach. & Thonn.) Hepper", # 1x 8k Miller
#         "Vachellia gerrardii (Benth.) P.J.H.Hurter & Mabb.", # 2x 12k Miller
#         "Vachellia negrii (Pic.Serm.) Kyal. & Boatwr.", # 1x 10k
#         "Vachellia nilotica (L.) P.J.H.Hurter & Mabb." # 1x Field Miller
# )