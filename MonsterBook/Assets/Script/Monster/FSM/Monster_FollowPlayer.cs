using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM
{
    public class Monster_FollowPlayer : MonsterFSMBase
    {        
        private GameObject Player;
        

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);
            
            Monster.gAnimator.SetTrigger("Run");
            if (Player == null)
                Player = GameObject.FindGameObjectWithTag("Player");
        }
        public override void FixedExecute(Rigidbody rigid)
        {
            if (Player == null) return;

            var dir = (Player.transform.position - Monster.transform.position);            
            Monster.transform.LookAt(Player.transform);
            Monster.transform.eulerAngles = Vector3.Scale(new Vector3(0.0f , 1.0f , 0.0f), Monster.transform.eulerAngles);            
            Move(rigid, dir, Monster.gRunSpeed);
        }

        public override void UpdateExecute()
        {
            if (Player == null) return;

        }
    }
}
