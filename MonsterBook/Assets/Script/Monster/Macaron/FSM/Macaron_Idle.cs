using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM.MacaronFSM
{
    public class Macaron_Idle : MonsterFSMBase
    {

        private Macaron MacaronMon;
        private float StartAttackDelay;

        public void init(MonsterBase MonsterController, bool TimeReset = true, bool isHit = false)
        {
            Monster = MonsterController;
            MacaronMon = Monster as Macaron;
            MacaronMon.gAnimator.SetTrigger("Idle");
            //if (isHit == true)
                //MacaronMon.gIsAttackChecker = isHit;
        }


        public override void FixedExecute(Rigidbody rigid)
        {

        }

        //public override MonsterFSMBase Transition()
        //{
        //    var HitCheck = MacaronMon.gFindMonsterScript.MonsterFSMState<MonsterHitState>();
        //    if (HitCheck || MacaronMon.gIsAttackChecker)
        //    {
        //
        //        
        //            return Macaron_FSMCarete.CreateAttack(Monster);
        //        
        //    }
        //
        //    return this;
        //}
        public override void UpdateExecute()
        {

        }
    }
}


