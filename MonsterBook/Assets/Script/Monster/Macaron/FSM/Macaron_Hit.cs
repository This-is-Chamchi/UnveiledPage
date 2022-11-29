using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM.MacaronFSM
{
    public class Macaron_Hit : MonsterFSMBase
    {

        private Macaron MacaronMon;
        private float StartAttackDelay;
        private bool Attack;


        public void init(MonsterBase MonsterController, bool isAttack = false)
        {
            Monster = MonsterController;
            Attack = isAttack;
            MacaronMon = Monster as Macaron;
            MacaronMon.gAnimator.ResetTrigger("Idle");
            MacaronMon.gAnimator.SetTrigger("Hit");
        }
        public override void FixedExecute(Rigidbody rigid)
        {

        }

        //public override MonsterFSMBase Transition()
        //{
        //
        //    if (MacaronMon.AnimationTrigger.gisAnimationEnd)
        //    {
        //        return Macaron_FSMCarete.CreateIdle(Monster, true, true);
        //    }
        //    return this;
        //}

        public override void UpdateExecute()
        {

        }
    }
}

