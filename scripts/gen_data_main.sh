#!/bin/bash
mkdir /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2



mkdir /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2/withoutTransMatch
cp /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2/2016-02-21@17-39-34/detailRT*.csv /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2/withoutTransMatch/
cp aggregate*.py  /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2/withoutTransMatch




cd /home/hshan/rubbos/results/2016-02-21T113750-0600_hshan-111-c2/withoutTransMatch


python aggregateInOutPut_ClientTier2.py          20160221114100-4459 201602211141 201602211144 3000
python aggregateInOutPut_ClientTier_longReq.py  20160221114100-4459 201602211141 201602211144 3000

