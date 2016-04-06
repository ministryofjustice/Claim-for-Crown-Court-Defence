CertificationType.delete_all
CertificationType.create!(name: 'I attended the main hearing (1st day of trial)', pre_may_2015: false, roles: ['agfs'])
CertificationType.create!(name: 'I notified the court, in writing before the PCMH that I was the instructed advocate. A copy of the letter is attached.', pre_may_2015: true, roles: ['agfs'])
CertificationType.create!(name: 'I attended the PCMH (where the client was arraigned) and no other advocate wrote to the court prior to this to advice that they were the instructed advocate.', pre_may_2015: true, roles: ['agfs'])
CertificationType.create!(name: 'I attended the first hearing after the PCMH and no other advocate attended the PCMH or wrote to the court prior to this to advise that they were the instructed advocate.', pre_may_2015: true, roles: ['agfs'])
CertificationType.create!(name: 'The previous instructed advocate notified the court in writing that they were no longer acting in this case and I was then instructed.', pre_may_2015: true, roles: ['agfs'])
CertificationType.create!(name: 'The case was a fixed fee (with a case number beginning with an S or A) and I attended the main hearing.', pre_may_2015: true, roles: ['agfs'])
CertificationType.create!(name: 'LGFS certification', roles: ['lgfs'])
