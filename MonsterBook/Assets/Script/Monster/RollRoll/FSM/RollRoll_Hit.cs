using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM.RollRollFSM
{

    public class RollRoll_Hit : MonsterFSMBase 
    {

        RollRoll RollRollMon;

        public void init(MonsterBase MonsterController)
        {
            Monster = MonsterController;
            RollRollMon = Monster as RollRoll;            
        }



        public override void FixedExecute(Rigidbody rigid)
        {
            
        }

        //public override MonsterFSMBase Transition()
        //{
        //    if (RollRollMon.gAnimationTrigger.gisAnimationEnd)
        //    {
        //        
        //        if (RollRollMon.gIsChase)
        //        {
        //            return RollRollFSMCreator.CreateRunning(RollRollMon);
        //        }
        //        else 
        //        {
        //            return RollRollFSMCreator.CreatePatrol(RollRollMon);
        //        }                
        //    }
        //    return this;
        //}

        public override void UpdateExecute()
        {
            
        }
    }
}
