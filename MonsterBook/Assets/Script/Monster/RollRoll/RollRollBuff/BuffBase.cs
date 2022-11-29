using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class BuffBase : MonoBehaviour
{

    public struct BuffDataTable
    {
        private int Damage;
        private float Speed;                
        private float Duration;
        private float CurrentDuration;      

        

        public int gDamage { get { return Damage; } set { Damage = value; } }
        public float gSpeed { get { return Speed; } set { Speed = value; } }
        public float gDuration { get { return Duration; } set { Duration = value; } }
        public float gCurrentDuration { get { return CurrentDuration; } set { CurrentDuration = value; } }
    }


    [SerializeField]
    private string BuffName;

    private Transform MySelf;
    private Transform Caster;
    private BuffDataTable DataTable;

    public Transform gCaster => Caster;
    public Transform gMySelf => MySelf;    
    public BuffDataTable gDataTable => DataTable;
    public string gBuffName {get {return BuffName;} protected set { BuffName = value;}}


    protected virtual void Update()
    {
        DataTable.gCurrentDuration += Time.deltaTime;

        if (DataTable.gCurrentDuration >= DataTable.gDuration)
        {
            Destroy(gameObject); 
            DataTable.gCurrentDuration = 0.0f;
        }
    }

    


    public static BuffBase GenerateBuff(Transform from , Transform to , GameObject BuffObject , BuffDataTable Table)
    {
        BuffBase buff = Instantiate(BuffObject , to).GetComponent<BuffBase>();
        buff.MySelf = to;
        buff.Caster = from;       
        buff.DataTable = Table;
        return buff;
    }

    public static BuffBase GenerateBuff(Transform to , GameObject BuffObject, BuffDataTable Table)
    {
        BuffBase buff = Instantiate(BuffObject , to).GetComponent<BuffBase>();        
        buff.MySelf = to;
        buff.DataTable = Table;
        return buff;
    }
    
}
