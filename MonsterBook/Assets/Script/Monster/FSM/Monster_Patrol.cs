using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Patrol : MonsterFSMBase
    {
        private bool VisitePatrolPoint;
        public bool gVisitePatrolPoint => VisitePatrolPoint;

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);
            Monster.gAnimator.SetTrigger("Walk");
            VisitePatrolPoint = false;
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            AngleTurn(MovePatrolCallBack);
            Move(rigid, Monster.transform.forward, Monster.gWalkSpeed);
        }

        private void MovePatrolCallBack()
        {
            VisitePatrolPoint = true;
        }

        public override void UpdateExecute()
        {
            
        }
    }
}
    