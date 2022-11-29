using System.Collections;
using System.Collections.Generic;
using UnityEngine;



namespace MonsterFSM
{

    public class Monster_NormalAttack : MonsterFSMAttack
    {        
        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);            
            gAttackMonster.gCurrentAttackDelay = Time.time;
            _Monster.gAnimator.SetTrigger("NormalAttack");
            LookAtTarget();           
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            
        }

        public override void UpdateExecute()
        {
            
        }

        private void LookAtTarget()
        {
            transform.LookAt(gAttackMonster.gAttackChecer.gTargetPos);
            var EulerAngle = transform.transform.rotation.eulerAngles;
            EulerAngle.Scale(new Vector3(0.0f, 1.0f ,0.0f));            
        }
    }
}

