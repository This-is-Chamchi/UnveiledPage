using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Jump : MonsterFSMBase
    {

        public Vector3 TargetDirection;
        private bool isInit;

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);
            isInit = false;
            //Monster.gAnimator.SetTrigger("Destruct");
        }
        public override void FixedExecute(Rigidbody rigid)
        {
            if (isInit == false)
            {
                JumpForce(TargetDirection, rigid);
                isInit = true;
            }
        }

        public override void UpdateExecute()
        {

        }

        

        private void JumpForce(Vector2 maxHeightDisplacement, Rigidbody rigid)
        {
            // m*k*g*h = m*v^2/2 (단, k == gravityScale) <= 역학적 에너지 보존 법칙 적용            
            // m*k*g*h = m*v^2/2 (단, k == gravityScale) <= 역학적 에너지 보존 법칙 적용
            float v_y = Mathf.Sqrt(2 * -Physics.gravity.y * maxHeightDisplacement.y);
            // 포물선 운동 법칙 적용
            float v_x = maxHeightDisplacement.x * v_y / (2 * maxHeightDisplacement.y);

            Vector3 force = rigid.mass * (new Vector3(v_x, v_y, 0.0f) - rigid.velocity);
            rigid.AddForce(force, ForceMode.Impulse);
        }


    }

}


/*
private void JumpForce(Vector2 maxHeightDisplacement)
{
    Rigidbody2D rigid = this.rigid;

    // m*k*g*h = m*v^2/2 (단, k == gravityScale) <= 역학적 에너지 보존 법칙 적용
    float v_y = Mathf.Sqrt(2 * rigid.gravityScale * -Physics2D.gravity.y * maxHeightDisplacement.y);
    // 포물선 운동 법칙 적용
    float v_x = maxHeightDisplacement.x * v_y / (2 * maxHeightDisplacement.y);

    Vector2 force = rigid.mass * (new Vector2(v_x, v_y) - rigid.velocity);
    rigid.AddForce(force, ForceMode2D.Impulse);
}

*/