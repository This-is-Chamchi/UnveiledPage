using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.ParticleSystemJobs;

public class Soup : MonoBehaviour
{
    public GameObject Gretel;
    public bool Solid = false;
    public GameObject SolidFood;
    public bool down = true;
    public float DownSpeed = 0.12f;
    public GameObject Effect;
    public GameObject ExplosionEffect;
    private bool EffectOnOff = false;

    // Start is called before the first frame update
    void Start()
    {
        Gretel = GameObject.FindWithTag("Gretel");
        
    }
    private void Awake()
    {
        gameObject.tag = "Untagged";
    }

    // Update is called once per frame
    public void Create()
    {
        if(Solid == false)
        {
            //StartCoroutine(DestroySoup());

        }
        else
        {
            //StartCoroutine(DestroySolidSoup());
        }

    }

    public IEnumerator DestroySoup()
    {
        yield return new WaitForSecondsRealtime(0.3f);
        Soup_Object_Pool.ReturnObject(this);
    }
    private IEnumerator DestroySolidSoup()
    {
        yield return new WaitForSecondsRealtime(0.3f);
        Instantiate(SolidFood, new Vector3(this.transform.position.x, 0.0f, this.transform.position.z),new Quaternion(0,0,0,0));
        Soup_Object_Pool.ReturnObject(this);
    }
    void Update()
    {

    }
    private void OnTriggerEnter(Collider other)
    {
        
        if (other.tag == "Ground")
        {
            SoundManager.PlayVFXSound("1StageGretel_ChocolateDrop", transform.position);
            gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;
           gameObject.GetComponent<Rigidbody>().useGravity = false;
            SoundManager.PlayVFXSound("1StageGretel_ChocolateDropSizzle", transform.position);
            Effect.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            ExplosionEffect.GetComponent<ParticleSystem>().Play();


            if (Solid == true)
            {
                StartCoroutine(DestroySolidSoup());
            }
            else
            {
 
                StartCoroutine(DestroySoup());
            }

        }


        else if(other.tag == "Boss")
        {
            if(SolidFood == true)
            {
                //Effect.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                //ExplosionEffect.GetComponent<ParticleSystem>().Play();

                //gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;
                gameObject.tag = "BossBuff";
 
            }
        }
        /*
          else if(other.tag == "Boss")
        {
            if(SolidFood == true)
            {

                gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;
                gameObject.GetComponent<Rigidbody>().useGravity = false;
                Effect.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                ExplosionEffect.GetComponent<ParticleSystem>().Play();

                gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;
                gameObject.tag = "BossBuff";
  

                if (Solid == true)
                {
                    StartCoroutine(DestroySolidSoup());
                }
                else
                {
                    StartCoroutine(DestroySoup());
                }
            }
        }
         
         */

        else if (other.tag == "Player")
        {
            gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;
            gameObject.GetComponent<Rigidbody>().useGravity = false;

            Effect.GetComponent<ParticleSystem>().Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            ExplosionEffect.GetComponent<ParticleSystem>().Play();

            gameObject.GetComponent<Rigidbody>().velocity = Vector3.zero;

            IEntity entity = other.GetComponent<IEntity>();
            if (entity != null) entity.OnDamage(other.gameObject.GetComponent<PlayerController>().isDamage, transform.position);
            if (Solid == true)
            {
                StartCoroutine(DestroySolidSoup());
            }
            else
            {
                StartCoroutine(DestroySoup());
            }
        }
    }

}
