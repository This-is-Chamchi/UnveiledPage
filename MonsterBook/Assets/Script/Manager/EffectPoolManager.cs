using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class EffectPoolManager : MonoBehaviour
{

    [System.Serializable]
    public struct EffectStruct
    {
        [SerializeField]
        private GameObject Effect;
        [SerializeField]
        private float Duration;


        public GameObject gEffect => Effect;
        public float gDuration => Duration;
    }





    [SerializeField]
    private List<EffectStruct> EffectPrefabs;
    private Dictionary<string, EffectStruct> EffectPrefabsDic = new Dictionary<string, EffectStruct>();
    private Dictionary<string, Queue<GameObject>> DontUsedEffect = new Dictionary<string, Queue<GameObject>>();
    private List<(string ,GameObject)> UseEffect = new List<(string, GameObject)>();
    private static EffectPoolManager Instance;
    public static EffectPoolManager gInstance => Instance;




    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(Instance.gameObject);
        }
        else
        {
            foreach(var item in Instance.UseEffect)
            {
                item.Item2.SetActive(false);
                DontUsedEffect[item.Item1].Enqueue(item.Item2);   
            }
            
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        foreach (var item in EffectPrefabs)
        {
            EffectPrefabsDic.Add(item.gEffect.name, item);
        }
    }



    public void LoadEffect(string EffectName, Transform trans, Transform Parent = null)
    {        
        LoadEffect(EffectName, trans.position, trans.rotation, Parent);
    }

    public void LoadEffect(string EffectName, Vector3 Position, Transform Parent = null)
    {        
        LoadEffect(EffectName, Position, Quaternion.identity, Parent);
    }




    public void LoadEffect(string EffectName, Vector3 Position, Quaternion Rot, Transform Parent = null)
    {

        if (Parent == null)
        {
            Parent = Instance.transform;
        }
        if (!EffectPrefabsDic.ContainsKey(EffectName))
        {
            Debug.LogError("(scriptName)EffectPoolManager : EffectPrefab이 존재 하지 않습니다.");
            return;
        }
        if (!DontUsedEffect.ContainsKey(EffectName))
        {
            DontUsedEffect.Add(EffectName, new Queue<GameObject>());
        }

        if (DontUsedEffect[EffectName].Count == 0)
        {
            var Clone = Instantiate(EffectPrefabsDic[EffectName].gEffect, Position, Rot, Parent);
            UseEffect.Add((EffectName , Clone));
            StartCoroutine(UsingEffect(Clone ,EffectName, EffectPrefabsDic[EffectName].gDuration));

        }
        else
        {
            var Effect = DontUsedEffect[EffectName].Dequeue();
            Effect.transform.position = Position;
            Effect.transform.rotation = Rot;
            UseEffect.Add((EffectName , Effect));
            StartCoroutine(UsingEffect(Effect, EffectName, EffectPrefabsDic[EffectName].gDuration));
        }
    }

    private IEnumerator UsingEffect(GameObject CloneObj ,string Name, float Duration)
    {
        CloneObj.SetActive(true);
        yield return new WaitForSeconds(Duration);        
        CloneObj.SetActive(false);
        DontUsedEffect[Name].Enqueue(CloneObj);        
        UseEffect.Remove((Name, CloneObj));
    }





}
