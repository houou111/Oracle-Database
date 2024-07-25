--============
http://surachartopun.com/2012/01/create-2nd-standby-database-from-1st.html

--============check capacity before restore
select name,free_mb/1024, total_mb/1024 from v$asm_diskgroup;

--============list backup 
--esb
/usr/openv/netbackup/bin/bplist  -C dr-esb-db01-pub -t 4 -S dr-backup-01 -s 03/11/2017 00:00:00 -e 03/12/2017 00:00:00 -l -b -R /
/usr/openv/netbackup/bin/bplist  -C dr-esb-db02-pub -t 4 -S dr-backup-01 -s 03/11/2017 00:00:00 -e 03/12/2017 00:00:00 -l -b -R /


--tcbs
/usr/openv/netbackup/bin/bplist  -C dr-tcbs-db-01 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 02/20/2017 00:00:00 -e 03/20/2017 00:00:00 -l -b -R /

--t24
/usr/openv/netbackup/bin/bplist  -C t24db04 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 04/20/2017 00:00:00 -e 04/22/2017 00:00:00 -l -b -R /
--============restore spfile  --> fix pfile or fix pfile 




---------
-rw-rw---- oracle    oinstall     33292288 Aug 11 07:01 /c-2153479117-20170811-03
-rw-rw---- oracle    oinstall     33292288 Aug 11 07:00 /ctrl_Cobr14drT24LIVE_uensbk78k_s4567_p1_t951721236
-rw-rw---- oracle    oinstall     33292288 Aug 11 07:00 /c-2153479117-20170811-02
-rw-rw---- oracle    oinstall       262144 Aug 11 06:56 /arch_Cobr14drT24LIVE_uelsbk717_s4565_p1_t951720999
-rw-rw---- oracle    oinstall     3646976K Aug 11 06:55 /arch_Cobr14drT24LIVE_ueksbk6vf_s4564_p1_t951720943
-rw-rw---- oracle    oinstall    422576128 Aug 11 06:55 /arch_Cobr14drT24LIVE_uejsbk6v0_s4563_p1_t951720928
-rw-rw---- oracle    oinstall     3646464K Aug 11 06:54 /arch_Cobr14drT24LIVE_ueisbk6sv_s4562_p1_t951720863
-rw-rw---- oracle    oinstall     3519232K Aug 11 06:53 /arch_Cobr14drT24LIVE_uehsbk6ri_s4561_p1_t951720818
-rw-rw---- oracle    oinstall     3649280K Aug 11 06:52 /arch_Cobr14drT24LIVE_uegsbk6ot_s4560_p1_t951720733
-rw-rw---- oracle    oinstall     3530240K Aug 11 06:49 /arch_Cobr14drT24LIVE_uefsbk6kc_s4559_p1_t951720588
-rw-rw---- oracle    oinstall     7366912K Aug 11 06:49 /arch_Cobr14drT24LIVE_ueesbk6iu_s4558_p1_t951720542
-rw-rw---- oracle    oinstall     3535104K Aug 11 06:44 /arch_Cobr14drT24LIVE_uedsbk6av_s4557_p1_t951720287
-rw-rw---- oracle    oinstall     7299072K Aug 11 06:43 /arch_Cobr14drT24LIVE_uecsbk68u_s4556_p1_t951720222
-rw-rw---- oracle    oinstall    32917760K Aug 11 06:38 /arch_Cobr14drT24LIVE_uebsbk5v3_s4555_p1_t951719907
-rw-rw---- oracle    oinstall    10585088K Aug 11 06:34 /arch_Cobr14drT24LIVE_ueasbk5n3_s4554_p1_t951719651
-rw-rw---- oracle    oinstall    22657536K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue7sbk5n3_s4551_p1_t951719651
-rw-rw---- oracle    oinstall     9336832K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue9sbk5n3_s4553_p1_t951719651
-rw-rw---- oracle    oinstall     3528960K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue8sbk5n3_s4552_p1_t951719651
-rw-rw---- oracle    oinstall    33036544K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue4sbk5n3_s4548_p1_t951719651
-rw-rw---- oracle    oinstall    33093376K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue6sbk5n3_s4550_p1_t951719651
-rw-rw---- oracle    oinstall    32924672K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue5sbk5n3_s4549_p1_t951719651
-rw-rw---- oracle    oinstall    21411584K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue2sbk5n2_s4546_p1_t951719650
-rw-rw---- oracle    oinstall    32869376K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue1sbk5n2_s4545_p1_t951719650
-rw-rw---- oracle    oinstall    30456832K Aug 11 06:34 /arch_Cobr14drT24LIVE_ue3sbk5n2_s4547_p1_t951719650
-rw-rw---- oracle    oinstall     33292288 Aug 11 06:33 /c-2153479117-20170811-01
-rw-rw---- oracle    oinstall      3407872 Aug 11 06:32 /bk_Cobr14drT24LIVE_udvsbk5k0_s4543_p1_t951719552
-rw-rw---- oracle    oinstall   1064304640 Aug 11 06:32 /bk_Cobr14drT24LIVE_udusbk5jp_s4542_p1_t951719545
-rw-rw---- oracle    oinstall     2095616K Aug 11 06:32 /bk_Cobr14drT24LIVE_udtsbk5jp_s4541_p1_t951719545
-rw-rw---- oracle    oinstall     2090496K Aug 11 06:32 /bk_Cobr14drT24LIVE_udssbk5ji_s4540_p1_t951719538
-rw-rw---- oracle    oinstall     2095360K Aug 11 06:32 /bk_Cobr14drT24LIVE_udrsbk5jh_s4539_p1_t951719537
-rw-rw---- oracle    oinstall     2095616K Aug 11 06:32 /bk_Cobr14drT24LIVE_udqsbk5jh_s4538_p1_t951719537
-rw-rw---- oracle    oinstall     2091008K Aug 11 06:31 /bk_Cobr14drT24LIVE_udpsbk5io_s4537_p1_t951719512
-rw-rw---- oracle    oinstall     2061056K Aug 11 06:31 /bk_Cobr14drT24LIVE_udosbk5ih_s4536_p1_t951719505
-rw-rw---- oracle    oinstall     2026752K Aug 11 06:31 /bk_Cobr14drT24LIVE_udnsbk5ie_s4535_p1_t951719502
-rw-rw---- oracle    oinstall     2032896K Aug 11 06:31 /bk_Cobr14drT24LIVE_udmsbk5ic_s4534_p1_t951719500
-rw-rw---- oracle    oinstall     2097152K Aug 11 06:31 /bk_Cobr14drT24LIVE_udlsbk5ht_s4533_p1_t951719485
-rw-rw---- oracle    oinstall     2096640K Aug 11 06:31 /bk_Cobr14drT24LIVE_udksbk5hq_s4532_p1_t951719482
-rw-rw---- oracle    oinstall     3145216K Aug 11 06:31 /bk_Cobr14drT24LIVE_udjsbk5h0_s4531_p1_t951719456
-rw-rw---- oracle    oinstall     4165120K Aug 11 06:30 /bk_Cobr14drT24LIVE_udisbk5ft_s4530_p1_t951719421
-rw-rw---- oracle    oinstall     5237504K Aug 11 06:29 /bk_Cobr14drT24LIVE_udhsbk5eq_s4529_p1_t951719386
-rw-rw---- oracle    oinstall     6290176K Aug 11 06:27 /bk_Cobr14drT24LIVE_udgsbk5b6_s4528_p1_t951719270
-rw-rw---- oracle    oinstall     6285056K Aug 11 06:27 /bk_Cobr14drT24LIVE_udfsbk5b3_s4527_p1_t951719267
-rw-rw---- oracle    oinstall     7747328K Aug 11 06:27 /bk_Cobr14drT24LIVE_udesbk5b2_s4526_p1_t951719266
-rw-rw---- oracle    oinstall    10472192K Aug 11 06:27 /bk_Cobr14drT24LIVE_uddsbk5a9_s4525_p1_t951719241
-rw-rw---- oracle    oinstall    10484736K Aug 11 06:27 /bk_Cobr14drT24LIVE_udcsbk59q_s4524_p1_t951719226
-rw-rw---- oracle    oinstall    10477824K Aug 11 06:27 /bk_Cobr14drT24LIVE_udbsbk59i_s4523_p1_t951719218
-rw-rw---- oracle    oinstall    11534592K Aug 11 06:26 /bk_Cobr14drT24LIVE_udasbk593_s4522_p1_t951719203
-rw-rw---- oracle    oinstall    12583168K Aug 11 06:26 /bk_Cobr14drT24LIVE_ud9sbk593_s4521_p1_t951719203
-rw-rw---- oracle    oinstall    15710464K Aug 11 06:24 /bk_Cobr14drT24LIVE_ud8sbk54i_s4520_p1_t951719058
-rw-rw---- oracle    oinstall    17822464K Aug 11 06:24 /bk_Cobr14drT24LIVE_ud7sbk54a_s4519_p1_t951719050
-rw-rw---- oracle    oinstall    19805440K Aug 11 06:21 /bk_Cobr14drT24LIVE_ud5sbk4v5_s4517_p1_t951718885
-rw-rw---- oracle    oinstall    18869760K Aug 11 06:21 /bk_Cobr14drT24LIVE_ud6sbk4v5_s4518_p1_t951718885
-rw-rw---- oracle    oinstall     2269184K Aug 11 06:21 /bk_Cobr14drT24LIVE_ud4sbk4uc_s4516_p1_t951718860
-rw-rw---- oracle    oinstall    21488128K Aug 11 06:20 /bk_Cobr14drT24LIVE_ud3sbk4sk_s4515_p1_t951718804
-rw-rw---- oracle    oinstall    26203648K Aug 11 06:19 /bk_Cobr14drT24LIVE_ud2sbk4qj_s4514_p1_t951718739
-rw-rw---- oracle    oinstall    27238400K Aug 11 06:18 /bk_Cobr14drT24LIVE_ud1sbk4pg_s4513_p1_t951718704
-rw-rw---- oracle    oinstall    27212544K Aug 11 06:18 /bk_Cobr14drT24LIVE_ud0sbk4om_s4512_p1_t951718678
-rw-rw---- oracle    oinstall    29319168K Aug 11 06:17 /bk_Cobr14drT24LIVE_ucusbk4nj_s4510_p1_t951718643
-rw-rw---- oracle    oinstall    27242496K Aug 11 06:17 /bk_Cobr14drT24LIVE_ucvsbk4nj_s4511_p1_t951718643
-rw-rw---- oracle    oinstall    30177024K Aug 11 06:14 /bk_Cobr14drT24LIVE_uctsbk4io_s4509_p1_t951718488
-rw-rw---- oracle    oinstall    31442176K Aug 11 06:09 /bk_Cobr14drT24LIVE_ucssbk488_s4508_p1_t951718152
-rw-rw---- oracle    oinstall    31565056K Aug 11 06:09 /bk_Cobr14drT24LIVE_ucrsbk488_s4507_p1_t951718152
-rw-rw---- oracle    oinstall    28835072K Aug 11 06:08 /bk_Cobr14drT24LIVE_ucqsbk475_s4506_p1_t951718117
-rw-rw---- oracle    oinstall    30593792K Aug 11 06:08 /bk_Cobr14drT24LIVE_ucpsbk461_s4505_p1_t951718081
-rw-rw---- oracle    oinstall    30235136K Aug 11 06:06 /bk_Cobr14drT24LIVE_ucosbk43m_s4504_p1_t951718006
-rw-rw---- oracle    oinstall    33545216K Aug 11 06:06 /bk_Cobr14drT24LIVE_ucnsbk43m_s4503_p1_t951718006
-rw-rw---- oracle    oinstall    33003264K Aug 11 06:06 /bk_Cobr14drT24LIVE_ucmsbk43m_s4502_p1_t951718006
-rw-rw---- oracle    oinstall    33551616K Aug 11 06:06 /bk_Cobr14drT24LIVE_uclsbk42j_s4501_p1_t951717971
-rw-rw---- oracle    oinstall    33543936K Aug 11 06:05 /bk_Cobr14drT24LIVE_ucksbk41p_s4500_p1_t951717945
-rw-rw---- oracle    oinstall    33288704K Aug 11 06:03 /bk_Cobr14drT24LIVE_ucjsbk3ti_s4499_p1_t951717810
-rw-rw---- oracle    oinstall    32749568K Aug 11 05:59 /bk_Cobr14drT24LIVE_ucisbk3lj_s4498_p1_t951717555
-rw-rw---- oracle    oinstall    33534720K Aug 11 05:58 /bk_Cobr14drT24LIVE_uchsbk3kp_s4497_p1_t951717529
-rw-rw---- oracle    oinstall    33533440K Aug 11 05:58 /bk_Cobr14drT24LIVE_ucgsbk3jc_s4496_p1_t951717484
-rw-rw---- oracle    oinstall    33518336K Aug 11 05:58 /bk_Cobr14drT24LIVE_ucfsbk3j5_s4495_p1_t951717477
-rw-rw---- oracle    oinstall    33532160K Aug 11 05:56 /bk_Cobr14drT24LIVE_ucesbk3g6_s4494_p1_t951717382
-rw-rw---- oracle    oinstall    33526528K Aug 11 05:55 /bk_Cobr14drT24LIVE_ucdsbk3f2_s4493_p1_t951717346
-rw-rw---- oracle    oinstall    32538880K Aug 11 05:55 /bk_Cobr14drT24LIVE_uccsbk3dl_s4492_p1_t951717301
-rw-rw---- oracle    oinstall    33545984K Aug 11 05:55 /bk_Cobr14drT24LIVE_ucbsbk3dl_s4491_p1_t951717301
-rw-rw---- oracle    oinstall    33518592K Aug 11 05:54 /bk_Cobr14drT24LIVE_ucasbk3bu_s4490_p1_t951717246
-rw-rw---- oracle    oinstall    32501504K Aug 11 05:53 /bk_Cobr14drT24LIVE_uc9sbk3ag_s4489_p1_t951717200
-rw-rw---- oracle    oinstall    33549824K Aug 11 05:48 /bk_Cobr14drT24LIVE_uc8sbk30v_s4488_p1_t951716895
-rw-rw---- oracle    oinstall    33544704K Aug 11 05:47 /bk_Cobr14drT24LIVE_uc7sbk2vi_s4487_p1_t951716850
-rw-rw---- oracle    oinstall    33521664K Aug 11 05:47 /bk_Cobr14drT24LIVE_uc6sbk2v2_s4486_p1_t951716834
-rw-rw---- oracle    oinstall    33517056K Aug 11 05:47 /bk_Cobr14drT24LIVE_uc5sbk2v2_s4485_p1_t951716834
-rw-rw---- oracle    oinstall    33440000K Aug 11 05:46 /bk_Cobr14drT24LIVE_uc4sbk2tb_s4484_p1_t951716779
-rw-rw---- oracle    oinstall    33432320K Aug 11 05:45 /bk_Cobr14drT24LIVE_uc3sbk2s8_s4483_p1_t951716744
-rw-rw---- oracle    oinstall    33378560K Aug 11 05:45 /bk_Cobr14drT24LIVE_uc2sbk2qr_s4482_p1_t951716699
-rw-rw---- oracle    oinstall    33547776K Aug 11 05:44 /bk_Cobr14drT24LIVE_uc1sbk2pd_s4481_p1_t951716653
-rw-rw---- oracle    oinstall    33519104K Aug 11 05:44 /bk_Cobr14drT24LIVE_uc0sbk2pc_s4480_p1_t951716652
-rw-rw---- oracle    oinstall    33539840K Aug 11 05:42 /bk_Cobr14drT24LIVE_ubvsbk2md_s4479_p1_t951716557
-rw-rw---- oracle    oinstall    33315840K Aug 11 05:37 /bk_Cobr14drT24LIVE_ubusbk2c7_s4478_p1_t951716231
-rw-rw---- oracle    oinstall    33341696K Aug 11 05:37 /bk_Cobr14drT24LIVE_ubtsbk2c0_s4477_p1_t951716224
-rw-rw---- oracle    oinstall    33540864K Aug 11 05:36 /bk_Cobr14drT24LIVE_ubssbk2at_s4476_p1_t951716189
-rw-rw---- oracle    oinstall    33529856K Aug 11 05:36 /bk_Cobr14drT24LIVE_ubrsbk2a4_s4475_p1_t951716164
-rw-rw---- oracle    oinstall    33534976K Aug 11 05:35 /bk_Cobr14drT24LIVE_ubqsbk29a_s4474_p1_t951716138
-rw-rw---- oracle    oinstall    33528832K Aug 11 05:35 /bk_Cobr14drT24LIVE_ubpsbk27t_s4473_p1_t951716093
-rw-rw---- oracle    oinstall    33388544K Aug 11 05:34 /bk_Cobr14drT24LIVE_ubosbk27s_s4472_p1_t951716092
-rw-rw---- oracle    oinstall    33405696K Aug 11 05:34 /bk_Cobr14drT24LIVE_ubnsbk265_s4471_p1_t951716037
-rw-rw---- oracle    oinstall    33429248K Aug 11 05:33 /bk_Cobr14drT24LIVE_ubmsbk251_s4470_p1_t951716001
-rw-rw---- oracle    oinstall    33408512K Aug 11 05:31 /bk_Cobr14drT24LIVE_ublsbk20g_s4469_p1_t951715856
-rw-rw---- oracle    oinstall    33378304K Aug 11 05:23 /bk_Cobr14drT24LIVE_ubksbk1hu_s4468_p1_t951715390
-rw-rw---- oracle    oinstall    33296384K Aug 11 05:23 /bk_Cobr14drT24LIVE_ubjsbk1hf_s4467_p1_t951715375
-rw-rw---- oracle    oinstall    33554432K Aug 11 05:23 /bk_Cobr14drT24LIVE_ubisbk1hf_s4466_p1_t951715375
-rw-rw---- oracle    oinstall    33554432K Aug 11 05:22 /bk_Cobr14drT24LIVE_ubhsbk1gc_s4465_p1_t951715340
-rw-rw---- oracle    oinstall    33265664K Aug 11 05:22 /bk_Cobr14drT24LIVE_ubgsbk1gc_s4464_p1_t951715340
-rw-rw---- oracle    oinstall    33501952K Aug 11 05:21 /bk_Cobr14drT24LIVE_ubfsbk1e0_s4463_p1_t951715264
-rw-rw---- oracle    oinstall    32524288K Aug 11 05:20 /bk_Cobr14drT24LIVE_ubesbk1d7_s4462_p1_t951715239
-rw-rw---- oracle    oinstall    32971264K Aug 11 05:20 /bk_Cobr14drT24LIVE_ubdsbk1bq_s4461_p1_t951715194
-rw-rw---- oracle    oinstall    33484288K Aug 11 05:19 /bk_Cobr14drT24LIVE_ubcsbk1bj_s4460_p1_t951715187
-rw-rw---- oracle    oinstall    33509888K Aug 11 05:17 /bk_Cobr14drT24LIVE_ubbsbk171_s4459_p1_t951715041
-rw-rw---- oracle    oinstall    33532416K Aug 11 05:08 /bk_Cobr14drT24LIVE_ubasbk0mk_s4458_p1_t951714516
-rw-rw---- oracle    oinstall    33455872K Aug 11 05:08 /bk_Cobr14drT24LIVE_ub9sbk0md_s4457_p1_t951714509
-rw-rw---- oracle    oinstall    33160448K Aug 11 05:08 /bk_Cobr14drT24LIVE_ub7sbk0lt_s4455_p1_t951714493
-rw-rw---- oracle    oinstall    32475136K Aug 11 05:08 /bk_Cobr14drT24LIVE_ub8sbk0lu_s4456_p1_t951714494
-rw-rw---- oracle    oinstall    33237248K Aug 11 05:07 /bk_Cobr14drT24LIVE_ub5sbk0l3_s4453_p1_t951714467
-rw-rw---- oracle    oinstall    33016832K Aug 11 05:07 /bk_Cobr14drT24LIVE_ub6sbk0l4_s4454_p1_t951714468
-rw-rw---- oracle    oinstall    33102336K Aug 11 05:07 /bk_Cobr14drT24LIVE_ub4sbk0ka_s4452_p1_t951714442
-rw-rw---- oracle    oinstall    33545728K Aug 11 05:07 /bk_Cobr14drT24LIVE_ub3sbk0k2_s4451_p1_t951714434
-rw-rw---- oracle    oinstall    33475328K Aug 11 05:06 /bk_Cobr14drT24LIVE_ub2sbk0il_s4450_p1_t951714389
-rw-rw---- oracle    oinstall    33444096K Aug 11 05:06 /bk_Cobr14drT24LIVE_ub1sbk0i6_s4449_p1_t951714374
-rw-rw---- oracle    oinstall    33425152K Aug 11 04:56 /bk_Cobr14drT24LIVE_uavsbk00g_s4447_p1_t951713808
-rw-rw---- oracle    oinstall    33420800K Aug 11 04:56 /bk_Cobr14drT24LIVE_ub0sbk00g_s4448_p1_t951713808
-rw-rw---- oracle    oinstall    33085440K Aug 11 04:56 /bk_Cobr14drT24LIVE_uatsbjvvm_s4445_p1_t951713782
-rw-rw---- oracle    oinstall    32976640K Aug 11 04:56 /bk_Cobr14drT24LIVE_uausbjvvn_s4446_p1_t951713783
-rw-rw---- oracle    oinstall    33464576K Aug 11 04:56 /bk_Cobr14drT24LIVE_uassbjvv7_s4444_p1_t951713767
-rw-rw---- oracle    oinstall    33516032K Aug 11 04:56 /bk_Cobr14drT24LIVE_uarsbjvv6_s4443_p1_t951713766
-rw-rw---- oracle    oinstall    33526784K Aug 11 04:56 /bk_Cobr14drT24LIVE_uaqsbjvv6_s4442_p1_t951713766
-rw-rw---- oracle    oinstall    33538560K Aug 11 04:56 /bk_Cobr14drT24LIVE_uapsbjvv5_s4441_p1_t951713765
-rw-rw---- oracle    oinstall    33549056K Aug 11 04:55 /bk_Cobr14drT24LIVE_uaosbjvu2_s4440_p1_t951713730
-rw-rw---- oracle    oinstall    32234496K Aug 11 04:55 /bk_Cobr14drT24LIVE_uansbjvu2_s4439_p1_t951713730
-rw-rw---- oracle    oinstall    32398592K Aug 11 04:46 /bk_Cobr14drT24LIVE_uamsbjvd0_s4438_p1_t951713184
-rw-rw---- oracle    oinstall    32767232K Aug 11 04:46 /bk_Cobr14drT24LIVE_ualsbjvch_s4437_p1_t951713169
-rw-rw---- oracle    oinstall    33335808K Aug 11 04:45 /bk_Cobr14drT24LIVE_uaksbjvbo_s4436_p1_t951713144
-rw-rw---- oracle    oinstall    32993536K Aug 11 04:45 /bk_Cobr14drT24LIVE_uajsbjvbo_s4435_p1_t951713144
-rw-rw---- oracle    oinstall    32529408K Aug 11 04:45 /bk_Cobr14drT24LIVE_uaisbjvau_s4434_p1_t951713118
-rw-rw---- oracle    oinstall    33537280K Aug 11 04:45 /bk_Cobr14drT24LIVE_uahsbjvat_s4433_p1_t951713117
-rw-rw---- oracle    oinstall    33180416K Aug 11 04:45 /bk_Cobr14drT24LIVE_uagsbjvae_s4432_p1_t951713102
-rw-rw---- oracle    oinstall    33215488K Aug 11 04:44 /bk_Cobr14drT24LIVE_uafsbjv9l_s4431_p1_t951713077
-rw-rw---- oracle    oinstall    33076992K Aug 11 04:44 /bk_Cobr14drT24LIVE_uaesbjv95_s4430_p1_t951713061
-rw-rw---- oracle    oinstall    33241088K Aug 11 04:44 /bk_Cobr14drT24LIVE_uadsbjv94_s4429_p1_t951713060
-rw-rw---- oracle    oinstall    32996096K Aug 11 04:34 /bk_Cobr14drT24LIVE_uacsbjun5_s4428_p1_t951712485
-rw-rw---- oracle    oinstall    33496320K Aug 11 04:34 /bk_Cobr14drT24LIVE_uabsbjun2_s4427_p1_t951712482
-rw-rw---- oracle    oinstall    33535488K Aug 11 04:34 /bk_Cobr14drT24LIVE_uaasbjumr_s4426_p1_t951712475
-rw-rw---- oracle    oinstall    33541376K Aug 11 04:34 /bk_Cobr14drT24LIVE_ua9sbjumn_s4425_p1_t951712471
-rw-rw---- oracle    oinstall    33549056K Aug 11 04:34 /bk_Cobr14drT24LIVE_ua8sbjumn_s4424_p1_t951712471
-rw-rw---- oracle    oinstall    33518592K Aug 11 04:34 /bk_Cobr14drT24LIVE_ua7sbjum8_s4423_p1_t951712456
-rw-rw---- oracle    oinstall    33500928K Aug 11 04:34 /bk_Cobr14drT24LIVE_ua6sbjum8_s4422_p1_t951712456
-rw-rw---- oracle    oinstall    33545216K Aug 11 04:33 /bk_Cobr14drT24LIVE_ua5sbjul5_s4421_p1_t951712421
-rw-rw---- oracle    oinstall    33387008K Aug 11 04:33 /bk_Cobr14drT24LIVE_ua4sbjukl_s4420_p1_t951712405
-rw-rw---- oracle    oinstall    33520640K Aug 11 04:33 /bk_Cobr14drT24LIVE_ua3sbjuji_s4419_p1_t951712370
-rw-rw---- oracle    oinstall    33529600K Aug 11 04:23 /bk_Cobr14drT24LIVE_ua1sbju1s_s4417_p1_t951711804
-rw-rw---- oracle    oinstall    33501952K Aug 11 04:23 /bk_Cobr14drT24LIVE_ua2sbju1t_s4418_p1_t951711805
-rw-rw---- oracle    oinstall    33552128K Aug 11 04:23 /bk_Cobr14drT24LIVE_ua0sbju1l_s4416_p1_t951711797
-rw-rw---- oracle    oinstall    33472000K Aug 11 04:23 /bk_Cobr14drT24LIVE_u9vsbju1e_s4415_p1_t951711790
-rw-rw---- oracle    oinstall    33551104K Aug 11 04:23 /bk_Cobr14drT24LIVE_u9usbju1b_s4414_p1_t951711787
-rw-rw---- oracle    oinstall    33549312K Aug 11 04:23 /bk_Cobr14drT24LIVE_u9tsbju0s_s4413_p1_t951711772
-rw-rw---- oracle    oinstall    33541120K Aug 11 04:22 /bk_Cobr14drT24LIVE_u9rsbju0r_s4411_p1_t951711771
-rw-rw---- oracle    oinstall    33548544K Aug 11 04:22 /bk_Cobr14drT24LIVE_u9ssbju0r_s4412_p1_t951711771
-rw-rw---- oracle    oinstall    33550592K Aug 11 04:22 /bk_Cobr14drT24LIVE_u9qsbju02_s4410_p1_t951711746
-rw-rw---- oracle    oinstall    33537536K Aug 11 04:22 /bk_Cobr14drT24LIVE_u9psbjtuv_s4409_p1_t951711711
-rw-rw---- oracle    oinstall    33537280K Aug 11 04:12 /bk_Cobr14drT24LIVE_u9osbjtcl_s4408_p1_t951711125
-rw-rw---- oracle    oinstall    33533696K Aug 11 04:12 /bk_Cobr14drT24LIVE_u9nsbjtce_s4407_p1_t951711118
-rw-rw---- oracle    oinstall    31899136K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9msbjtbv_s4406_p1_t951711103
-rw-rw---- oracle    oinstall    33121280K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9lsbjtbu_s4405_p1_t951711102
-rw-rw---- oracle    oinstall    32962560K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9jsbjtbn_s4403_p1_t951711095
-rw-rw---- oracle    oinstall    33075968K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9ksbjtbn_s4404_p1_t951711095
-rw-rw---- oracle    oinstall    33166592K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9isbjtbn_s4402_p1_t951711095
-rw-rw---- oracle    oinstall    32992512K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9hsbjtbf_s4401_p1_t951711087
-rw-rw---- oracle    oinstall    33222400K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9gsbjtbc_s4400_p1_t951711084
-rw-rw---- oracle    oinstall    33072384K Aug 11 04:11 /bk_Cobr14drT24LIVE_u9fsbjtas_s4399_p1_t951711068
-rw-rw---- oracle    oinstall    33528576K Aug 11 04:00 /bk_Cobr14drT24LIVE_u9esbjsmn_s4398_p1_t951710423
-rw-rw---- oracle    oinstall    33516032K Aug 11 04:00 /bk_Cobr14drT24LIVE_u9csbjsmn_s4396_p1_t951710423
-rw-rw---- oracle    oinstall    32973568K Aug 11 04:00 /bk_Cobr14drT24LIVE_u9dsbjsmn_s4397_p1_t951710423
-rw-rw---- oracle    oinstall    33296128K Aug 11 04:00 /bk_Cobr14drT24LIVE_u98sbjsmn_s4392_p1_t951710423
-rw-rw---- oracle    oinstall    32961280K Aug 11 04:00 /bk_Cobr14drT24LIVE_u9bsbjsmn_s4395_p1_t951710423
-rw-rw---- oracle    oinstall    32258304K Aug 11 04:00 /bk_Cobr14drT24LIVE_u9asbjsmn_s4394_p1_t951710423
-rw-rw---- oracle    oinstall    32691968K Aug 11 04:00 /bk_Cobr14drT24LIVE_u99sbjsmn_s4393_p1_t951710423
-rw-rw---- oracle    oinstall    33372672K Aug 11 04:00 /bk_Cobr14drT24LIVE_u95sbjsmm_s4389_p1_t951710422
-rw-rw---- oracle    oinstall    33530880K Aug 11 04:00 /bk_Cobr14drT24LIVE_u97sbjsmn_s4391_p1_t951710423
-rw-rw---- oracle    oinstall    33499904K Aug 11 04:00 /bk_Cobr14drT24LIVE_u96sbjsmn_s4390_p1_t951710423
---------
run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-tcbs-db-01,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
restore spfile from '/ctrl_Cobr14drT24LIVE_uensbk78k_s4567_p1_t951721236';
release channel t1;
}
create pfile from spfile;
--> fix
-----
cobr14dr.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
*.audit_file_dest='/u01/app/oracle/admin/cob10/adump'
*.audit_sys_operations=TRUE
*.audit_trail='DB'
*.compatible='11.2.0.4.0'
*.db_block_size=8192
*.db_create_file_dest='+TESTR14SSD'
*.db_domain=''
*.db_flashback_retention_target=2880
*.db_name='T24LIVE'
*.db_recovery_file_dest='+TESTR14SSD'
*.db_recovery_file_dest_size=2199023255552
*.db_unique_name='cob10'
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=cobXDB)'
*.fast_start_mttr_target=1800
*.local_listener='LISTENER_COB10'
*.log_archive_dest_1='LOCATION=+TESTR14SSD'
*.open_cursors=5000
*.open_links=10
*.optimizer_index_caching=50
*.optimizer_index_cost_adj=1
*.pga_aggregate_target=15461253120
*.processes=6605
*.query_rewrite_integrity='TRUSTED'
*.recyclebin='OFF'
*.remote_login_passwordfile='EXCLUSIVE'
*.service_names='cobr14dr'
*.session_cached_cursors=1000
*.session_max_open_files=500
*.sga_max_size=50G
*.sga_target=50G
*.standby_file_management='AUTO'
*.undo_retention=54000
*.undo_tablespace='UNDOTBS1'
-----

startup nomount pfile=''
create spfile from pfile='';
--============restore controlfile
run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=t24db04,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
restore controlfile from '/ctrl_Cobr14drT24LIVE_uensbk78k_s4567_p1_t951721236';
release channel t1;
}

alter system set control_files='' scope=spfile;
startup mount force
--fix pfile
-->create spfile from pfile;
-->startup mount;

--============restore database
select 'set newname for datafile '||file_id ||' to ''+TESTR14''' from dba_datafiles order by file_id;


run{
set until time "to_date('2017-08-12:00:46:00', 'yyyy-mm-dd:hh24:mi:ss')";
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
allocate channel t3 device type 'sbt_tape' ;
allocate channel t4 device type 'sbt_tape' ;
allocate channel t11 device type 'sbt_tape' ;
allocate channel t12 device type 'sbt_tape' ;
allocate channel t13 device type 'sbt_tape' ;
allocate channel t14 device type 'sbt_tape' ;
allocate channel t21 device type 'sbt_tape' ;
allocate channel t22 device type 'sbt_tape' ;
allocate channel t23 device type 'sbt_tape' ;
allocate channel t24 device type 'sbt_tape' ;
allocate channel t31 device type 'sbt_tape' ;
allocate channel t32 device type 'sbt_tape' ;
allocate channel t33 device type 'sbt_tape' ;
allocate channel t34 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=t24db04,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set newname for datafile 1 to '+TESTR14';
set newname for datafile 2 to '+TESTR14';
set newname for datafile 3 to '+TESTR14';
set newname for datafile 4 to '+TESTR14';
set newname for datafile 5 to '+TESTR14';
set newname for datafile 6 to '+TESTR14';
set newname for datafile 7 to '+TESTR14';
set newname for datafile 8 to '+TESTR14';
set newname for datafile 9 to '+TESTR14';
set newname for datafile 10 to '+TESTR14';
set newname for datafile 11 to '+TESTR14';
set newname for datafile 12 to '+TESTR14';
set newname for datafile 13 to '+TESTR14';
set newname for datafile 14 to '+TESTR14';
set newname for datafile 15 to '+TESTR14';
set newname for datafile 16 to '+TESTR14';
set newname for datafile 17 to '+TESTR14';
set newname for datafile 18 to '+TESTR14';
set newname for datafile 19 to '+TESTR14';
set newname for datafile 20 to '+TESTR14';
set newname for datafile 21 to '+TESTR14';
set newname for datafile 22 to '+TESTR14';
set newname for datafile 23 to '+TESTR14';
set newname for datafile 24 to '+TESTR14';
set newname for datafile 25 to '+TESTR14';
set newname for datafile 26 to '+TESTR14';
set newname for datafile 27 to '+TESTR14';
set newname for datafile 28 to '+TESTR14';
set newname for datafile 29 to '+TESTR14';
set newname for datafile 30 to '+TESTR14';
set newname for datafile 31 to '+TESTR14';
set newname for datafile 32 to '+TESTR14';
set newname for datafile 33 to '+TESTR14';
set newname for datafile 34 to '+TESTR14';
set newname for datafile 35 to '+TESTR14';
set newname for datafile 36 to '+TESTR14';
set newname for datafile 37 to '+TESTR14';
set newname for datafile 38 to '+TESTR14';
set newname for datafile 39 to '+TESTR14';
set newname for datafile 40 to '+TESTR14';
set newname for datafile 41 to '+TESTR14';
set newname for datafile 42 to '+TESTR14';
set newname for datafile 43 to '+TESTR14';
set newname for datafile 44 to '+TESTR14';
set newname for datafile 45 to '+TESTR14';
set newname for datafile 46 to '+TESTR14';
set newname for datafile 47 to '+TESTR14';
set newname for datafile 48 to '+TESTR14';
set newname for datafile 49 to '+TESTR14';
set newname for datafile 50 to '+TESTR14';
set newname for datafile 51 to '+TESTR14';
set newname for datafile 52 to '+TESTR14';
set newname for datafile 53 to '+TESTR14';
set newname for datafile 54 to '+TESTR14';
set newname for datafile 55 to '+TESTR14';
set newname for datafile 56 to '+TESTR14';
set newname for datafile 57 to '+TESTR14';
set newname for datafile 58 to '+TESTR14';
set newname for datafile 59 to '+TESTR14';
set newname for datafile 60 to '+TESTR14';
set newname for datafile 61 to '+TESTR14';
set newname for datafile 62 to '+TESTR14';
set newname for datafile 63 to '+TESTR14';
set newname for datafile 64 to '+TESTR14';
set newname for datafile 65 to '+TESTR14';
set newname for datafile 66 to '+TESTR14';
set newname for datafile 67 to '+TESTR14';
set newname for datafile 68 to '+TESTR14';
set newname for datafile 69 to '+TESTR14';
set newname for datafile 70 to '+TESTR14';
set newname for datafile 71 to '+TESTR14';
set newname for datafile 72 to '+TESTR14';
set newname for datafile 73 to '+TESTR14';
set newname for datafile 74 to '+TESTR14';
set newname for datafile 75 to '+TESTR14';
set newname for datafile 76 to '+TESTR14';
set newname for datafile 77 to '+TESTR14';
set newname for datafile 78 to '+TESTR14';
set newname for datafile 79 to '+TESTR14';
set newname for datafile 80 to '+TESTR14';
set newname for datafile 81 to '+TESTR14';
set newname for datafile 82 to '+TESTR14';
set newname for datafile 83 to '+TESTR14';
set newname for datafile 84 to '+TESTR14';
set newname for datafile 85 to '+TESTR14';
set newname for datafile 86 to '+TESTR14';
set newname for datafile 87 to '+TESTR14';
set newname for datafile 88 to '+TESTR14';
set newname for datafile 89 to '+TESTR14';
set newname for datafile 90 to '+TESTR14';
set newname for datafile 91 to '+TESTR14';
set newname for datafile 92 to '+TESTR14';
set newname for datafile 93 to '+TESTR14';
set newname for datafile 94 to '+TESTR14';
set newname for datafile 95 to '+TESTR14';
set newname for datafile 96 to '+TESTR14';
set newname for datafile 97 to '+TESTR14';
set newname for datafile 98 to '+TESTR14';
set newname for datafile 99 to '+TESTR14';
set newname for datafile 100 to '+TESTR14';
set newname for datafile 101 to '+TESTR14';
set newname for datafile 102 to '+TESTR14';
set newname for datafile 103 to '+TESTR14';
set newname for datafile 104 to '+TESTR14';
set newname for datafile 105 to '+TESTR14';
set newname for datafile 106 to '+TESTR14';
set newname for datafile 107 to '+TESTR14';
set newname for datafile 108 to '+TESTR14';
set newname for datafile 109 to '+TESTR14';
set newname for datafile 110 to '+TESTR14';
set newname for datafile 111 to '+TESTR14';
set newname for datafile 112 to '+TESTR14';
set newname for datafile 113 to '+TESTR14';
set newname for datafile 114 to '+TESTR14';
set newname for datafile 115 to '+TESTR14';
set newname for datafile 116 to '+TESTR14';
set newname for datafile 117 to '+TESTR14';
set newname for datafile 118 to '+TESTR14';
set newname for datafile 119 to '+TESTR14';
set newname for datafile 120 to '+TESTR14';
set newname for datafile 121 to '+TESTR14';
set newname for datafile 122 to '+TESTR14';
set newname for datafile 123 to '+TESTR14';
set newname for datafile 124 to '+TESTR14';
set newname for datafile 125 to '+TESTR14';
set newname for datafile 126 to '+TESTR14';
set newname for datafile 127 to '+TESTR14';
set newname for datafile 128 to '+TESTR14';
set newname for datafile 129 to '+TESTR14';
set newname for datafile 130 to '+TESTR14';
set newname for datafile 131 to '+TESTR14';
set newname for datafile 132 to '+TESTR14';
set newname for datafile 133 to '+TESTR14';
set newname for datafile 134 to '+TESTR14';
set newname for datafile 135 to '+TESTR14';
set newname for datafile 136 to '+TESTR14';
set newname for datafile 137 to '+TESTR14';
set newname for datafile 138 to '+TESTR14';
set newname for datafile 139 to '+TESTR14';
set newname for datafile 140 to '+TESTR14';
set newname for datafile 141 to '+TESTR14';
set newname for datafile 142 to '+TESTR14';
set newname for datafile 143 to '+TESTR14';
set newname for datafile 144 to '+TESTR14';
set newname for datafile 145 to '+TESTR14';
set newname for datafile 146 to '+TESTR14';
set newname for datafile 147 to '+TESTR14';
set newname for datafile 148 to '+TESTR14';
set newname for datafile 149 to '+TESTR14';
set newname for datafile 150 to '+TESTR14';
set newname for datafile 151 to '+TESTR14';
set newname for datafile 152 to '+TESTR14';
set newname for datafile 153 to '+TESTR14';
set newname for datafile 154 to '+TESTR14';
set newname for datafile 155 to '+TESTR14';
restore database;
switch datafile all;
release channel t1;
release channel t2;
release channel t3;
release channel t4;
release channel t11;
release channel t12;
release channel t13;
release channel t14;
release channel t21;
release channel t22;
release channel t23;
release channel t24;
release channel t31;
release channel t32;
release channel t33;
release channel t34;
}

--============check capacity before restore
select name,free_mb/1024, total_mb/1024 from v$asm_diskgroup;

--turn off flashbask if it's on
alter database flashback off;

--============recover database 
run{
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
allocate channel t3 device type 'sbt_tape' ;
allocate channel t4 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=t24db04,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
recover database until time "to_date('2017-08-12:00:46:00', 'yyyy-mm-dd:hh24:mi:ss')";
release channel t1;
release channel t2;
release channel t3;
release channel t4;
}


--============Neu restore tu ban backup tren standby DB --> tao lai control file or activate standby
alter database activate physical standby database;

--ghi controlfile ra trace file
alter database backup controlfile to trace;

CREATE CONTROLFILE REUSE DATABASE "FLEX" RESETLOGS FORCE LOGGING ARCHIVELOG
    MAXLOGFILES 40
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 9348
LOGFILE
  GROUP 2 (
    '+DATA/flexres/onlinelog/group_2.282.924893603',
    '+FRA/flexres/onlinelog/group_2.823.924893603'
  ) SIZE 100M BLOCKSIZE 512,
  GROUP 10 (
    '+DATA/flexres/onlinelog/group_10.286.924893605',
    '+FRA/flexres/onlinelog/group_10.802.924893605'
  ) SIZE 100M BLOCKSIZE 512
DATAFILE
  '+FRA/flexres/datafile/system.640.939380437',
  '+FRA/flexres/datafile/sysaux.1292.939380437',
  '+DATA/flexres/datafile/undotbs1.289.939380435',
  '+DATA/flexres/datafile/users.287.939380495',
  '+DATA/flexres/datafile/undotbs2.288.939380437'
CHARACTER SET AL32UTF8
;

--============open reset log
alter database open resetlogs;

--chuyen ve noarchivelog mode
alter database noarchivelog;

-------------------------------------------------------------------------------------------
archive log
-------------------------------------------------------------------------------------------
run {
backup archivelog thread 1  sequence 4438 format '/restore_temp/restore/201703/backup_arc/%U';
}

catalog start with '/u01/app/oracle/diag/rdbms/esbdata2/esbdata21/trace/backup_arc_new';

run {
SET ARCHIVELOG DESTINATION TO '+FRA01_DR/esbdata2/archivelog/res/';
RESTORE ARCHIVELOG sequence 4438 thread 1;
RESTORE ARCHIVELOG FROM TIME = "to_date('2014-01-19 19:20:00','YYYY-DD-MM HH24:MI:SS')"  
                    UNTIL TIME = "to_date('2014-01-19 20:00:00','YYYY-DD-MM HH24:MI:SS')";
}

-------------------------------------------------------------------------------------------
Dataguard
-------------------------------------------------------------------------------------------
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
BACKUP INCREMENTAL  FROM SCN 13243534264 DATABASE FORMAT '/u01/app/oracle/backup/backup_%U' tag 'FORSTANDBY';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}

catalog start with '/u01/app/oracle/backup/';

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
backup as compressed backupset datafile 1,2,3,4,5 FORMAT '/u01/app/oracle/backup/new_%U' tag 'FOR_STANDBY';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}


ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

select file#, min(to_char(checkpoint_change#)) from v$datafile_header group by file#;

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
restore datafile 1,2,3,4,5 ;
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}