import FWCore.ParameterSet.Config as cms
process = cms.Process("ProcessOne")
process.load("CondCore.DBCommon.CondDBCommon_cfi")
process.CondDBCommon.connect = 'sqlite_file:fillinfo_pop_test.db'
process.CondDBCommon.DBParameters.authenticationPath = '.'
process.CondDBCommon.DBParameters.messageLevel=cms.untracked.int32(1)

process.MessageLogger = cms.Service("MessageLogger",
                                    cout = cms.untracked.PSet(threshold = cms.untracked.string('INFO')),
                                    destinations = cms.untracked.vstring('cout')
                                    )

process.source = cms.Source("EmptyIOVSource",
                            lastValue = cms.uint64(1),
                            timetype = cms.string('runnumber'),
                            firstValue = cms.uint64(1),
                            interval = cms.uint64(1)
                            )

process.PoolDBOutputService = cms.Service("PoolDBOutputService",
                                          process.CondDBCommon,
                                          logconnect = cms.untracked.string('sqlite_file:logfillinfo_pop_test.db'),
                                          timetype = cms.untracked.string('timestamp'),
                                          toPut = cms.VPSet(cms.PSet(record = cms.string('FillInfoRcd'),
                                                                     tag = cms.string('fillinfo_test')
                                                                     )
                                                            )
                                          )

process.Test1 = cms.EDAnalyzer("FillInfoPopConAnalyzer",
                               SinceAppendMode = cms.bool(True),
                               record = cms.string('FillInfoRcd'),
                               name = cms.untracked.string('FillInfo'),
                               Source = cms.PSet(fill = cms.untracked.uint32(6303),
                                   firstFill = cms.untracked.uint32( 5500 ),
                                   lastFill = cms.untracked.uint32( 5510 ),
                                   connectionString = cms.untracked.string("oracle://cms_orcon_adg/CMS_RUNTIME_LOGGER"),
                                   DIPSchema = cms.untracked.string("CMS_BEAM_COND"),
                                   authenticationPath =  cms.untracked.string("."),
                                   debug=cms.untracked.bool(True)
                                                 ),
                               loggingOn = cms.untracked.bool(True),
                               IsDestDbCheckedInQueryLog = cms.untracked.bool(False)
                               )

process.p = cms.Path(process.Test1)
