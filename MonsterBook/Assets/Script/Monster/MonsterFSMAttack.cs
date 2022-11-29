using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM
{


    public abstract class MonsterFSMAttack : MonsterFSMBase
    {        
        protected bool AttackEnd = false;
        public bool gAttackEnd => AttackEnd;
        protected AttackMonster gAttackMonster
        {
            get {
                    var TempAttackMonster = Monster as AttackMonster;
                    if (TempAttackMonster == null)
                    {
                        Debug.LogError("Monster_NormalAttack : AttackMonster가 아닙니다.");                
                    }
                    return TempAttackMonster;
                }

        }
        
        
    }
}

