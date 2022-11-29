using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations.Rigging;

namespace MonsterFSM
{
    public class Monster_Hit : MonsterFSMBase
    {
        private bool InitCheck = false;

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);            
            Monster.gAnimator.SetTrigger("Hit");
            Monster.gAnimationTrigger.gisAnimationEnd = false;
            InitCheck = true;
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            if (InitCheck)
            {
                rigid.velocity = new Vector3(0.0f , 0.0f , 0.0f);
                InitCheck = false;
            }            
        }

        public override void UpdateExecute()
        {
            
        }
    }
}