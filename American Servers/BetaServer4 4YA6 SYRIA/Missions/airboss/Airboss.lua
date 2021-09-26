-- Airboss


carrier=UNIT:FindByName("Naval-1-2")

airboss1=AIRBOSS:New(carrier:GetName(), "Naval-1-2")
airboss1:SetTACAN(11, "X", "C74")
airboss1:SetICLS(11, "C74")
airboss1:SetDefaultPlayerSkill(AIRBOSS.Difficulty.NORMAL)
airboss1:SetMenuRecovery(60, 25, true, 0)
airboss1:SetPatrolAdInfinitum(switch)
airboss1:SetAirbossNiceGuy()
airboss1:SetSoundfilesFolder("Airboss Soundfiles/")
airboss1:SetDespawnOnEngineShutdown()
airboss1:SetRespawnAI()
airboss1:SetVoiceOversLSOByFF()
airboss1:SetVoiceOversMarshalByRaynor()
airboss1:Start()

carrier=UNIT:FindByName("Naval-1-1")

airboss2=AIRBOSS:New(carrier:GetName(), "Naval-1-1")
airboss2:SetTACAN(10, "X", "C71")
airboss2:SetICLS(10, "C71")
airboss2:SetDefaultPlayerSkill(AIRBOSS.Difficulty.NORMAL)
airboss2:SetMenuRecovery(60, 25, true, 0)
airboss2:SetPatrolAdInfinitum(switch)
airboss2:SetAirbossNiceGuy()
airboss2:SetSoundfilesFolder("Airboss Soundfiles/")
airboss2:SetDespawnOnEngineShutdown()
airboss2:SetRespawnAI()
airboss2:SetVoiceOversLSOByFF()
airboss2:SetVoiceOversMarshalByRaynor()
airboss2:Start()

      



 
