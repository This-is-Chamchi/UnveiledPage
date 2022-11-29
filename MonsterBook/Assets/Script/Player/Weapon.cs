using UnityEngine;

public class Weapon : MonoBehaviour{
    private Collider coll;
    private int damage;

    public bool isCutting;


    private void Awake(){
        coll = GetComponent<Collider>();

        coll.enabled = false;
    }

    public void SetDamage(int value){
        damage = value;
    }

    public void Collider(bool value){
        coll.enabled = value;
    }

    public void SetTrigger(bool value){
        coll.enabled = value;
    }

    private void OnTriggerEnter(Collider other){
        IEntity entity = other.GetComponent<IEntity>();

        if (entity != null){
            entity.OnDamage(damage, transform.parent.position);
            if (isCutting){
                ICutOff cut = other.GetComponent<ICutOff>();

                if (cut != null && cut.CheckCutOff()) cut.CutDamage();
            }
        }
    }
}
