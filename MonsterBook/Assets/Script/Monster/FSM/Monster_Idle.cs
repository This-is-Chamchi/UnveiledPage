using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Idle : MonsterFSMBase
    {
        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);            
            Monster.gAnimator.SetTrigger("Idle");
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            
        }

        public override void UpdateExecute()
        {
            
        }
    }
}

