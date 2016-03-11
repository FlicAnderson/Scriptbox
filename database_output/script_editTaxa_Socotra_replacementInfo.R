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
# ....  lumped as "A b". Where there are a species ("A b") and a subspecies which 
# ....  is NOT an autonym (ie it may be "A b subsp/var c"), this has been lumped 
# ....  as "A b".  Where there are several subspecies ("A b subsp/var b", "A b 
# ....  subsp/var c", "A b subsp/var d"), these have all been lumped into "A b".
# ....  
# ---------------------------------------------------------------------------- #


toReplace <- c("Achyranthes aspera L. var. aspera",
"Achyranthes aspera var. pubescens (Moq.) C.C.Towns.",
"Aerva javanica (Burm.f.) Juss. var. javanica",
"Aerva javanica var. bovei Webb",
"Amaranthus graecizans L. subsp. graecizans",
"Adenium obesum subsp. sokotranum (Vierh.) Lavranos",
"Digera muricata subsp. trinervis var. patentipilosa C.C.Towns.",
"Asparagus africanus var. microcarpus Balf.f.",
"Commiphora ornifolia var. glabra (Radcl.-Sm.) J.B.Gillett",
"Wahlenbergia lobelioides subsp. nutabunda (Guss.) Murb.",
"Capparis spinosa L. var. spinosa",
"Maerua angolensis subsp. socotrana (Schweinf. ex Balf.f.) Kers",
"Maerua angolensis var. socotrana Schweinf. ex Balf.f.",
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
"Fimbristylis cymosa var. spathacea (Roth) T. Koyama",
"Andrachne schweinfurthii var. papillosa Radcl.-Sm.",
"Euphorbia arbuscula var. montana Balf.f.",
"Euphorbia balsamifera subsp. adenensis (Deflers) P.R.O.Bally",
"Eleusine coracana subsp. africana (Kenn.-O'Byrne) S.M.Philips",
"Hypericum socotranum R.D.Good subsp. socotranum",
"Hypericum socotranum subsp. smithii N.Robson",
"Indigofera tinctoria L. var. tinctoria",
"Microcharis disjuncta var. fallax (J.B.Gillett) Schrire",
"Rhynchosia minima (L.) DC. var. minima",
"Teramnus repens subsp. gracilis (Chiov.) Verdc.",
"Jasminum fluminense subsp. socotranum P.S.Green",
"Anagallis arvensis var. caerulea (L.) Gouan",
"Diodia aulacosperma var. angustata Verdc.",
"Dodonaea viscosa subsp. angustifolia (L.f.) J.G.West",
"Solanum villosum subsp. miniatum (Bernh. ex Willd. ) Edmonds",
"Sterculia africana (Lour.) Fiori subsp. africana",
"Sterculia africana subsp. socotrana Abedin",
"Viola cinerea Boiss. var. stocksii")

replaceWith <- c("Achyranthes aspera L.",
"Achyranthes aspera L.",
"Aerva javanica (Burm.f.) Juss.",
"Aerva javanica (Burm.f.) Juss.",
"Amaranthus graecizans L.",
"Adenium obesum (Forssk.) Roem. & Schult.",
"Digera muricata (L.) Mart.",
"Asparagus africanus Lam.",
"Commiphora ornifolia (Balf.f.) J.B.Gillett",
"Wahlenbergia lobelioides DC.",
"Capparis spinosa L.",
"Maerua angolensis DC.",
"Maerua angolensis DC.",
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
"Fimbristylis cymosa R.Br.",
"Andrachne schweinfurthii (Balf.f.) Radcl.-Sm.",
"Euphorbia arbuscula Balf.f.",
"Euphorbia balsamifera Aiton",
"Eleusine coracana (L.) Gaertn.",
"Hypericum socotranum R.D.Good",
"Hypericum socotranum R.D.Good",
"Indigofera tinctoria L.",
"Microcharis disjuncta (J.B.Gillett) Schrire",
"Rhynchosia minima (L.) DC.",
"Teramnus repens (Taub.) Baker f.",
"Jasminum fluminense Vell.",
"Anagallis arvensis L.",
"Diodia aulacosperma K.Schum.",
"Dodonaea viscosa Jacq.",
"Solanum villosum (L.) Mill.",
"Sterculia africana (Lour.) Fiori",
"Sterculia africana (Lour.) Fiori",
"Viola cinerea Boiss.")

taxaFixes <<- data.frame(toReplace, replaceWith)