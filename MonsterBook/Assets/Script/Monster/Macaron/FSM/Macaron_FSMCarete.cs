using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM.MacaronFSM
{
    public static class Macaron_FSMCarete
    {

        public static MonsterFSMBase CreateIdle(MonsterBase Monster, bool TimeReset = true , bool isHit = false)
        {
            var Component = Monster.gameObject.GetComponent<Macaron_Idle>();
            if (Component == null)
                Component = Monster.gameObject.AddComponent<Macaron_Idle>();
            Component.init(Monster, TimeReset , isHit);
            return Component;
        }

        public static MonsterFSMBase CreateAttack(MonsterBase Monster)
        {
            var Component = Monster.gameObject.GetComponent<Macaron_Attack>();
            if (Component == null)
                Component = Monster.gameObject.AddComponent<Macaron_Attack>();
            Component.init(Monster);
            return Component;
        }

        public static MonsterFSMBase CreateHit(MonsterBase Monster, bool Attack = false)
        {
            var Component = Monster.gameObject.GetComponent<Macaron_Hit>();
            if (Component == null)
                Component = Monster.gameObject.AddComponent<Macaron_Hit>();
            Component.init(Monster, Attack);
            return Component;
        }

        public static MonsterFSMBase CreateDead(MonsterBase Monster)
        {
            var Component = Monster.gameObject.GetComponent<Macaron_Dead>();
            if (Component == null)
                Component = Monster.gameObject.AddComponent<Macaron_Dead>();
            Component.init(Monster);
            return Component;
        }


    }
}

