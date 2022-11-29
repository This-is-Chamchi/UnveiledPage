using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Flying : MonsterFSMBase
    {
        private float m_StartY;
        private bool m_End;

        public bool g_End => m_End;
        
        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);
            Monster.gAnimator.SetTrigger("Idle");
            Monster.gPlayerColloder.isTrigger = false;
            if (m_StartY == 0.0f)
                m_StartY = _Monster.transform.position.y;
            m_End = false;
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            var velocity = Vector3.zero;
            velocity.y = Monster.gWalkSpeed;
            
            if (Monster.transform.position.y >= m_StartY)
            {
                Monster.transform.position = new Vector3(Monster.transform.position.x, m_StartY, Monster.transform.position.z);
                rigid.velocity = Vector3.zero;
                m_End = true;
            }
            else
            {
                rigid.velocity = velocity;
            }
        }

        public override void UpdateExecute()
        {
            
        }
    }
}

